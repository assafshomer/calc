module BtcDoubleSpend
	def gamma(z,p)
		z*(1-p)/p if p>0 and p<=1 and z.class== Fixnum and z>=0
	end

	def satoshi(z,p) # z is the number of confirmations and p is the honest hashrate
		k_array=[]
		(0..z).each do |k|
			k_array<<(gamma(z,p)**k)*(Math.exp(-gamma(z,p))/fact(k))*(1-((1-p)/p)**(z-k))
		end
		return 1-k_array.inject(:+)
	end

	def meni(n,p) # n is the number of confirmations and p is the honest hashrate
		return 1 if n==0
		m_array=[]
		(0..n).each do |m|
			m_array << choose(n+m-1,m) * (p**n * (1-p)**m - p**m * (1-p)**n)
		end
		return 1-m_array.inject(:+)
	end

	def assaf_n_m(n,q) 
		return 1 if n==0
		m_array=[]
		(0..n).each do |m|
			m_array << choose(n+m-1,m) * ((1-q)**n * q**m - (1-q)**(m-1) * q**(n+1))
		end
		return 1-m_array.inject(:+)
	end

	def assaf_ds_prefix(n,p)
		return 0 if p==1 # basically with q=0 th attack cannot even start
		(1-p)**2 / (1-p**n * (1+n*(1-p)))
	end

	def assaf(n,p) # n is the number of confirmations and p is the honest hashrate
		return 1 if n==0
		return 0 if p==1
		m_array=[]
		(0..n).each do |m|
			m_array << assaf_ds_prefix(n,p) * choose(n+m+1,m+2) * (p**n * (1-p)**m - p**m * (1-p)**n)
		end
		return 1-m_array.inject(:+)
	end

	def assaf_ds_normalization(n,p)
		return 0 if p==1 # basically with q=0 th attack cannot even start
		(1-p**n * (1+n*(1-p)))
	end

	def check_assaf_ds_normalization(m_max,p,n)
		return 1 if p==1
		result_array=[]
		(0..m_max).each do |m|
			result_array << choose(m+n+1,m+2) * p**n * (1-p)**(m+2)
		end
		temp=result_array.inject(:+)/assaf_ds_normalization(n,p)
		(temp<0.001) ? 0 : temp
	end	

	def confirmations(b,p,n_max=200, method) 
		# searching for the minimal confirmation number where the probability is below a target
		#b is the target probability, p is honest hashrate and n_max is the maximal number of confirmations searched
		(0..n_max).each do |m|
			case method
				when 'satoshi'
					return m if satoshi(m,p) < b	
				when 'meni'
					return m if meni(m,p) < b	
				when 'assaf'
					return m if assaf(m,p) < b
				else
					return 'specify a method'	
			end			
		end
		'More than ' + n_max.to_s + ' confirmations are needed in this case'
	end


end
