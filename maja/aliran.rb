#$gintkel: remote code execution xglo

module Gintkel
	@cmd = BarisPerintah.new

	def self.markas
		return File.join(@cmd.environment_variable("APPDATA"), "gintkel")
	end

	def self.first_executor
		PemeriksaSpesifikasi
	end
end

class PembacaEnvironment < Executor
	def [](nEnv)
		return daftar[nEnv]
	end

	def persiapan
		@daftar = %w(
			APPDATA
			COMPUTERNAME
			OS
			HOMEDRIVE
			HOMEPATH
			PROCESSOR_ARCHITECTURE
			USERDOMAIN
			USERPROFILE
		)
	end

	def lancarkan
		p @daftar
	end
end

p PembacaEnvironment.new.lancarkan