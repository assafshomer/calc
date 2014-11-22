module BtcViewHelper
	def prepare_parray(p_min=0.5,granularity=10)
		return [p_min] if granularity<1 
		p_array=[]
		(0..granularity).each {|x| p_array<<p_min+x.fdiv((1/(1-p_min))*granularity)}
		result=p_array.map {|x| x.round(5)}
		return result
	end

	def prepare_qarray(q_min=0,q_max=1,granularity=10)
		return [q_min] if granularity<1
		q_array=[]
		(0..granularity).each {|x| q_array<<q_min+x.fdiv((1/(q_max-q_min))*granularity)}
		return q_array.map {|x| x.round(5)}
	end

	def prepare_xarray(x_min=0,x_max=1,steps=10, epsilon = 0.01)
		return [x_min] if steps<1
		x_array=[]
		(0..steps).each do |x|
			tmp = x_min+x.fdiv((1/(x_max.to_f-x_min.to_f))*steps)
			x_array << tmp unless (1-tmp).abs < epsilon
		end
		return x_array.map {|x| x.round(5)}
	end

	def prepare_header(min=0,max=10, label='p')
		header=[label]
		(min..max).each {|z| header << label+'='+z.to_s }
		return header
	end
end