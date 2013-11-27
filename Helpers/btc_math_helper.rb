module BtcMathHelper

	def fact(integer)
		return 1 if integer==0
		(1..integer).inject(:*) if integer.class == Fixnum
	end

	def choose(n,m)
		fact(n)/(fact(m)*fact(n-m)) unless m>n
	end
	
	def no_suffix(float)
		("%.20f" % float).sub(/\.?0*$/, "") if float.class==Float
	end	
end
