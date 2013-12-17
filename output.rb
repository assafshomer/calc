module BtcController

	require 'csv'
	require './Helpers/btc_math_helper.rb'
	require './Helpers/btc_view_helper.rb'
	require './Models/btc_double_spend.rb'
	require './Models/btc_block_survival.rb'

	include BtcViewHelper

	def path_prefix
		"./Views/HTML/CSV/"
	end

	def current_calculation(z,p)
		# satoshi(z,p)
		# meni(z,p)
		assaf(z,p)
	end		

	def show(z_max=10)
		p_array=[]
		(0..5).each {|x| p_array<<0.5+x.fdiv(10)}
		z_range=(0..z_max)		
		p_array.each do |p|
			z_range.each do |z|
				puts "p="+p.to_s+",z="+z.to_s+" => "+current_calculation(z,p).to_s
			end
		end		
	end

	def probability_tsv(z_min=0,z_max=10,p_min=0.5, granularity=5,filename)
		p_array=prepare_parray(p_min,granularity)
		header=prepare_header(z_min,z_max)
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			p_array.each do |p|
				result << p
				(z_min..z_max).each do |z|
					result << current_calculation(z,p)
				end
				csv << result
				result=[]
			end
		end		
	end

	def comparison_tsv(z=1,p_min=0.5, granularity=5,filename)
		p_array=prepare_parray(p_min,granularity)
		suffix= ' (z='+z.to_s+')'
		header=['p', 'satoshi'+suffix, 'meni'+suffix,'assaf'+suffix]
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			p_array.each do |p|
				result << p
				result << satoshi(z,p)
				result << meni(z,p)
				result << assaf(z,p)
				csv << result
				result=[]
			end
		end		
	end

	def confirmations_tsv(b=0.01,p_min=0.6, granularity=5,filename)
		p_array=prepare_parray(p_min,granularity)
		suffix= ' (p<'+(b*100).to_s+'%)'
		header=['p', 'satoshi'+suffix, 'meni'+suffix,'assaf'+suffix]
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			p_array.each do |p|
				result << p
				result << confirmations(b,p,200,'satoshi')
				result << confirmations(b,p,200,'meni')
				result << confirmations(b,p,200,'assaf')
				csv << result
				result=[]
			end
		end		
	end

	def normalization_tsv(n=5,z_min=0,z_max=10,p_min=0.5, granularity=5,filename)
		p_array=prepare_parray(p_min,granularity)
		header=prepare_header(z_min,z_max)
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			p_array.each do |p|
				result << p
				(z_min..z_max).each do |z|
					result << check_assaf_ds_normalization(z,p,n)
				end
				csv << result
				result=[]
			end
		end		
	end

	def normalization_rotated_tsv(n=5,z_max=10,p_min=0.5, granularity=5,filename)
		p_array=prepare_parray(p_min,granularity)
		header=['z']
		p_array.each {|p| header << 'p='+p.to_s }
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			(0..z_max).each do |z|
				result << z
				p_array.each do |p|
					result << check_assaf_ds_normalization(z,p,n).round(4)
				end
				csv << result
				result=[]
			end
		end		
	end

	def full_normalization_rotated_tsv(n=5,z_max=10,p_min=0.5,granularity=5,c=10,filename)
		p_array=prepare_parray(p_min,granularity)
		header=['z']
		p_array.each {|p| header << 'p='+p.to_s }
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			(0..z_max).each do |z|
				result << z
				p_array.each do |p|
					result << check_normalization(z,c,p,n)
				end
				csv << result
				result=[]
			end
		end		
	end

	def plot_stable_solution(p_min=0.6,granularity=5,n_min=50,n_max=400, step=25, precision=4,filename)
		p_array=prepare_parray(p_min,granularity)
		header=['p', 'foo']
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			p_array.each do |p|
				csv << [p,find_stable_solution(p,n_min,n_max,step,precision)]
			end
		end		
	end

	def plot_block_survival(n_min=0,n_max=10,p_min=0.5, granularity=5,filename)
		p_array=prepare_parray(p_min,granularity)
		header=prepare_header(n_min,n_max,'n')
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			p_array.each do |p|
				result << p
				(n_min..n_max).each do |n|
					result << chain_survival(p,n)
				end
				csv << result
				result=[]
			end
		end		
	end	

	def plot_new_block_survival(q_min=0, granularity=20,filename)
		q_array=prepare_parray(q_min,granularity)
		header=['q','Honest - q','Withholding - Q(q)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << q
				result << q
				result << new_chain_survival(q)
				csv << result
				result=[]
			end
		end		
	end	


	def plot_attackers_reward(q_min=0,q_max=1, granularity=20,filename)
		q_array=prepare_qarray(q_min,q_max,granularity)
		header=['q','Honest - q','Withholding - R(q)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << q
				result << q
				result << attackers_reward(q) unless attackers_reward(q)>5
				csv << result
				result=[]
			end
		end		
	end		

	def plot_q_critical(g_min=0,g_max=1, granularity=20,filename)
		g_array=prepare_qarray(g_min,g_max,granularity)
		header=['q', 'q_c=(1-2ɣ)/(2-2ɣ)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			g_array.each do |g|
				result << g
				result << q_crit(g) 
				csv << result
				result=[]
			end
		end		
	end	


	def plot_q_benefit(g_min=0,g_max=1, granularity=20,filename)
		g_array=prepare_qarray(g_min,g_max,granularity)
		header=['q', 'q_benefit=(1-3ɣ)/(3-3ɣ)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			g_array.each do |g|
				result << g
				result << q_benefit(g) unless q_benefit(g)<0
				csv << result 
				result=[]
			end
		end		
	end	


	def plot_gamma_attack(q_min=0,q_max=1,g_min=0,g_max=0.5, p_gran=20,q_gran=20,filename)
		q_array=prepare_qarray(q_min,q_max,p_gran)
		g_array=prepare_qarray(g_min,g_max,q_gran)
		header=['q','Honest','Type I']
		g_array.each {|g| header << 'ɣ='+g.to_s}
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << q
				result << q
				result << new_chain_survival(q)
				g_array.each do |g|
					result << gamma_attack(q,g) 
				end
				csv << result
				result=[]
			end
		end		
	end		

	def plot_gamma_focus(q_min=0,q_max=1,g_min=0.05,g_max=0.06, p_gran=20,q_gran=2,filename)
		q_array=prepare_qarray(q_min,q_max,p_gran)
		g_array=prepare_qarray(g_min,g_max,q_gran)
		header=['q','Type I']
		g_array.each {|g| header << 'ɣ='+g.to_s}
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << q
				result << new_chain_survival(q)
				g_array.each do |g|
					result << gamma_attack(q,g) 
				end
				csv << result
				result=[]
			end
		end		
	end	

	def plot_q_g_phase_space(g_min=0,g_max=1, granularity=20,filename)
		g_array=prepare_qarray(g_min,g_max,granularity)
		header=['q','q_0','q_+=1/4+√(1-17ɣ)(16-16ɣ)','q_=(1-3ɣ)/(3-3ɣ)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			g_array.each do |g|
				result << g
				result << q_0 unless g>0.058
				result << q_plus(g) unless g>0.058
				# result << q_minus(g) unless g>1/17.0
				result << q_benefit(g) unless q_benefit(g)<0 || g<0.058
				csv << result 
				result=[]
			end
		end		
	end		

end


