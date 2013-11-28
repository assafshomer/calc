module BtcViewHelper
	def prepare_parray(p_min,granularity)
		p_array=[]
		(0..granularity).each {|x| p_array<<p_min+x.fdiv((1/(1-p_min))*granularity)}
		result=p_array.map {|x| x.round(5)}
		return result
	end

	def prepare_qarray(q_min=0,q_max=1,granularity=10)
		q_array=[]
		(0..granularity).each {|x| q_array<<q_min+x.fdiv((1/(q_max-q_min))*granularity)}
		result=q_array.map {|x| x.round(5)}
		return result
	end

	def prepare_header(min=0,max=10, label='p')
		header=[label]
		(min..max).each {|z| header << label+'='+z.to_s }
		return header
	end
end