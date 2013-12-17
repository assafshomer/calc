module BtcBlockSurvival

	def normalization(p,n,c)
		# c is what I call L, the blockchain length
		r_array=[1]
		(2..c).each do |r|
			s_array = []
			(0..r-1).each do |s|
				s_array << p**(n+r) * (1-p)**s * choose(n+r+s-1,s)
			end
			r_array << 1-s_array.inject(:+)			
		end
		return r_array.inject(:+)			
	end


	def check_normalization(m_max,c,p,n)
		return 1 if p==1
		result_array=[]
		(0..m_max).each do |m|
			(1..c).each do |l|
				result_array << choose(m+n+2*l-1,m+l) * p**(n+l) * (1-p)**(m+l)
			end
		end
		result_array.inject(:+)/normalization(p,n,c)
		# (temp<0.001) ? 0 : temp
	end	

	def calculate_block_survival(c,p,n)
		return 1 if p==1
		result_array=[]
		(0..n-1).each do |m|
			(1..c).each do |l|
				result_array << choose(m+n+2*l-1,m+l) * (p**(n+l) * (1-p)**(m+l)- p**(m+l) * (1-p)**(n+l))
			end
		end
		1- (result_array.inject(:+)/normalization(p,n,c))
	end	

	def calculate_chain_replace(p,n_max=10,precision=4)
		q=1-p
		result_array=[]
		(1..n_max).each do |n|
			inner_array=[]
			(0..n).each do |m|
				inner_array << choose(n+m-1,m) * (p**m * q**n - p**n * q**m)
			end
			result_array << 1+ inner_array.inject(:+)
		end
		(2*q + result_array.inject(:+)).round(precision)
	end


	def find_stable_solution(p,n_min=50,n_max=400, step=25, precision=4)
		n=n_min
		while n<n_max do
			if calculate_chain_replace(p,n+step,precision)==calculate_chain_replace(p,n,precision)
				puts [p,calculate_chain_replace(p,n,precision),n].to_s
				# return [calculate_chain_replace(p,n,precision),n] if calculate_chain_replace(p,n+step,precision)==calculate_chain_replace(p,n,precision)
				return calculate_chain_replace(p,n,precision) 				
			end
			n+=step			
		end
		puts [p,calculate_chain_replace(p,n,precision),'no convergence at '+n_max.to_s].to_s
		calculate_chain_replace(p,n_max,precision)
	end

	def chain_survival(p,n)
		q=1-p
		return 'error' if n<0
		return 1 if q>=0.5	
		if n>0
			result_array=[]
			(0..n).each do |m|
				result_array << choose(n+m-1,m) * (p**m * q**n - p**n * q**m)
			end
			1+(q/p)*(result_array.inject(:+))
		else
			2*q
		end
	end	

	def chain_survival2(p,n)
		q=1-p
		return 'error' if n<0
		return 1 if q>=0.5	
		if n>0
			result_array=[]
			(0..n).each do |m|
				result_array << choose(n+m-1,m) * (p**m * q**n - p**n * q**m)
			end
			1+result_array.inject(:+)		
		else
			2*q
		end
	end		

	def new_chain_survival(q)
		return (3*q**2-2*q**3)/(1-q) if q<0.5
		1
	end	

	def attackers_reward(q)
		return (3*q**2-2*q**3)/(1-q) if q<0.5
		q/(1-q)
	end		

	def q_eff(q,g)
		q+g*(1-q)
	end

	def q_crit(g)
		(1-2*g)/(2-2*g)
	end

	def q_benefit(g)
		return (1-3*g)/(3-3*g) if g<0.33
		0
	end

	def q_selfish(g)
		(1-g)/(3-2*g) 
	end	

	def q_0
		1-(1/Math.sqrt(2))
	end

	def gamma_crit
		1-(2.0/3.0)*(Math.sqrt(2))
	end

	def q_plus(g)
		return 0.25*(1+Math.sqrt((1-17*g)/(1-g))) if g<1/17.0
		0
	end

	def q_minus(g)
		return 0.25*(1-Math.sqrt((1-17*g)/(1-g))) if g<1/17.0
		0
	end	

	def gamma_attack(q,g)
		if q<q_crit(g) && g<0.5
			return (2*q*q_eff(q,g))/(1-q_eff(q,g))	
		elsif q<0.5 
			return 2*q
		else
			return 1
		end
	end	

end
