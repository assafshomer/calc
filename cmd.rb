require './output.rb'
include BtcMathHelper
include BtcController
include BtcDoubleSpend
include BtcBlockSurvival

# p probability_tsv(1,10,0.5,25,'assaf')
# comparison_tsv(6,0.5,10,'compare')
# confirmations_tsv(0.001,0.8,20,'confirmations')
# p confirmations(0.001,0.7,200,'satoshi')
# p prepare_parray(0.8,10)
# p choose(4,5)
# p assaf(0,0.7)
# p assaf(3,0.7)
# p assaf(5,0.9)
# p satoshi(5,0.9)
# p strange_prefix(1,1)
# p normalization(0.8,0,50)
# p check_strange_normalization(200,0.7,60)
# p meni(0,0.8)
# check_strange_normalization(m_max,p,n)
# normalization_tsv(150,50,60,0.6,10,'normalization')
# normalization_rotated_tsv(10,200,0.6,10,'normalization_rotated')
# full_normalization_rotated_tsv(n=5,z_max=10,p_min=0.5,granularity=5,c=100,filename)
# full_normalization_rotated_tsv(50,55,0.7,5,20,'full_norm')
# calculate_block_survival(c,p,n)
# p calculate_block_survival(1,0.7,3)
# p calculate_chain_replace(0.9,100)
# p prepare_qarray(0.2,0.9)
# check_full_normalization(m_max,c,p,n)
# p check_full_normalization(50,200,0.9,20)
# p find_stable_solution(0.6)
# plot_block_survival(n_min=0,n_max=10,p_min=0.5, granularity=5,filename)
# plot_block_survival(0,50,0.5,100,'blocksurvive')
# plot_new_block_survival(0,50,'newblocksurvive')
# plot_attackers_reward(0,1,200,'attackersreward')
# p choose(3,2.5)
# p prepare_header(1,10,'n')
# p prepare_qarray(0,1,20)
# p prepare_parray
plot_gamma_attack(0,1,0,0.5,50,5,'gammaattack')
# plot_q_critical(0,0.5,20,'qcritical')
# plot_q_benefit(0,0.4,400,'qcritandbenefit')


