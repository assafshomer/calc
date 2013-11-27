module BtcViewHelper
	def prepare_parray(p_min,granularity)
		p_array=[]
		(0..granularity).each {|x| p_array<<p_min+x.fdiv((1/(1-p_min))*granularity)}
		result=p_array.map {|x| x.round(5)}
		return result
	end

	def prepare_header(min=0,max=10, label='p')
		header=[label]
		(min..max).each {|z| header << label+'='+z.to_s }
		return header
	end
end