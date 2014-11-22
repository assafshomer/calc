module BtcController

	require 'csv'
	require './Helpers/btc_math_helper.rb'
	require './Helpers/btc_view_helper.rb'
	require './Models/btc_double_spend.rb'
	require './Models/btc_block_survival.rb'
	require './Models/btc_duration.rb'

	include BtcViewHelper
	include BtcDuration

	def path_prefix
		"./Views/HTML/CSV/"
	end

	def current_calculation(z,q)
		satoshi(z,q)
		# meni(z,q)
		# assaf(z,q)
		# assaf_n_m(z,q)
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

	def probability_tsv(z_min=1,z_max=10,q_min=0,q_max=0.5, granularity=5,filename,round)
		q_array=prepare_qarray(q_min,q_max,granularity)
		header=prepare_header(z_min,z_max,'z')
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << q
				(z_min..z_max).each do |z|
					result << current_calculation(z,q).round(round)
				end
				csv << result
				result=[]
			end
		end		
	end
	def satoshi_tsv(z_min=1,z_max=10,q_min=0,q_max=0.5, granularity=5,filename,round)
		q_array=prepare_qarray(q_min,q_max,granularity)
		header=prepare_header(z_min,z_max,'z')
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << (q*100).round.to_s+'%'
				(z_min..z_max).each do |z|
					result << (satoshi(z,q)*100).round(3).to_s+'%'
				end
				csv << result
				result=[]
			end
		end		
	end
	def meni_tsv(z_min=1,z_max=10,q_min=0,q_max=0.5, granularity=5,filename,round)
		q_array=prepare_qarray(q_min,q_max,granularity)
		header=prepare_header(z_min,z_max,'z')
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << (q*100).round.to_s+'%'
				(z_min..z_max).each do |z|
					result << (meni(z,q)*100).round(3).to_s+'%'
				end
				csv << result
				result=[]
			end
		end		
	end
	def assaf_tsv(z_min=1,z_max=10,q_min=0,q_max=0.5, granularity=5,filename,round)
		q_array=prepare_qarray(q_min,q_max,granularity)
		header=prepare_header(z_min,z_max,'z')
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << (q*100).round.to_s+'%'
				(z_min..z_max).each do |z|
					result << (assaf_n_m(z,q)*100).round(3).to_s+'%'
				end
				csv << result
				result=[]
			end
		end		
	end			

	def comparison_tsv(z=1,q_min=0,q_max=0.5, granularity=5,filename,round)
		q_array=prepare_qarray(q_min,q_max,granularity)
		suffix= ' (z='+z.to_s+')'
		header=['q','assaf'+suffix, 'satoshi'+suffix,'meni'+suffix]
		# header=['q','satoshi'+suffix, 'meni'+suffix]
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			q_array.each do |q|
				result << q
				result << assaf_n_m(z,q).round(round)
				result << satoshi(z,q).round(round)
				result << meni(z,q).round(round)
				# result << assaf(z,q)
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
		header=['q','Standard: P=q','Type I: P=Q(q)']
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
		header=['q','q_c(ɣ)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			g_array.each do |g|
				result << g
				result << q_crit(g) unless q_crit(g)<0
				csv << result
				result=[]
			end
		end		
	end	


	def plot_q_benefit(g_min=0,g_max=1, granularity=20,filename)
		g_array=prepare_qarray(g_min,g_max,granularity)
		header=['q', 'q_b=(1-3ɣ)/(3-3ɣ)']
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

	def plot_q_selfish(g_min=0,g_max=1, granularity=20,filename)
		g_array=prepare_qarray(g_min,g_max,granularity)
		header=['q', 'q_b=(1-3ɣ)/(3-3ɣ)','q_s=(1-ɣ)/(3-2ɣ)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			g_array.each do |g|
				result << g
				result << q_benefit(g)
				# result << q_crit(g)
				result << q_selfish(g)
				csv << result 
				result=[]
			end
		end		
	end		
# 'q_c=(1-2ɣ)/(2-2ɣ)',

	def plot_gamma_attack(q_min=0,q_max=1,g_min=0,g_max=0.5, p_gran=20,q_gran=20,filename)
		q_array=prepare_qarray(q_min,q_max,p_gran)
		g_array=prepare_qarray(g_min,g_max,q_gran)
		header=['q','Standard: P=q','Type I: P=Q(q)']
		g_array.each {|g| header << 'Type 0: P=S(ɣ,q) with ɣ='+g.to_s}
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
		header=['q','q_0','q_+=1/4+√(1-17ɣ)(16-16ɣ)','q_b=(1-3ɣ)/(3-3ɣ)']
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

	def phase_space_focus(g_min=0,g_max=0.06, granularity=20,filename)
		g_array=prepare_qarray(g_min,g_max,granularity)
		header=['q','q_0','q_+=1/4+√(1-17ɣ)(16-16ɣ)','q_b=(1-3ɣ)/(3-3ɣ)']
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			g_array.each do |g|
				result << g
				result << q_0 
				result << q_plus(g) unless g>1/17.0
				result << q_minus(g) unless g>1/17.0
				result << q_benefit(g) unless q_benefit(g)<0 || g<0.058
				csv << result 
				result=[]
			end
		end		
	end

	def plot_duration(x=[0,1,10],z=[1,6],a=12,filename='duration')
		x_array=prepare_qarray(x[0],x[1],x[2])
		p x_array
		z_array=(z[0]..z[1]).to_a
		p z_array		
		header=['x']
		z_array.each {|z| header << 'z='+z.to_s}
		result=[]
		CSV.open(path_prefix+filename+".csv", "wb", col_sep: "	") do |csv|		
			csv << header
			x_array.each do |x|
				result << x											
				z_array.each do |z|
					result << durationx(x,z,a).round(2)					
				end
				csv << result
				result=[]
			end
		end		
	end

end


