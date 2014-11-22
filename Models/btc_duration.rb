module BtcDuration

	def duration(q,z,a)
		raise '0<z<a' if z<0 || z>a-1
		raise '0<q<1' if q<0 || q>1
		x = (q/(1-q))
		f = (1-x**z)/(1-x**a)
		g = (1+x)/(1-x)
		g*(a*f-z)
	end

	def durationx(x,z,a)
		raise 'z should be an integer' unless z.class == Fixnum 
		raise 'a should be an integer' unless a.class == Fixnum 
		raise '0<z<a' if z<0 || z>a-1 
		raise '0<x' if x<0
		f = (1-x**z).fdiv(1-x**a)
		g = (1+x).fdiv(1-x)
		g*(a*f-z).round(2)
	end

end


=begin
in an irb console
require '/home/assaf/ruby_projects/Calc/Models/btc_duration'
include BtcDuration
=end