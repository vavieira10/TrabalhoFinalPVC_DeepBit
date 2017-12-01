%% Projeto final de PVC - 2/2017 
%Andre Luis Souto Ferreira - 140016261
%Victor Araujo Vieira - 14/0032801

%% Script que executa os comandos necessarios para aplicar o modelo deepbit treinado nas imagens de insetos
% Sera dividido em 4 partes: Inicializacao dos dados, extracao dos
% descritores binarios para todas imagens(dividindo as imagens em treino e teste),
% treinamento da SVM e, por ultimo, o teste da eficiencia do classificador.

%% Inicializacao dos dados
% Parte do script que vai preparar os dados

close all;
clear;

addpath(genpath(pwd));

% variaveis do caffe
addpath('/home/victor/UnB/Semestre8/PVC/Projetos/ProjetoFinal/cvpr16-deepbit/matlab');

% modelo deepbit
model_file = '/home/victor/UnB/Semestre8/PVC/Projetos/ProjetoFinal/cvpr16-deepbit/models/deepbit/DeepBit32_final_iter_1.caffemodel';
% definicao do modelo
model_def_file = '/home/victor/UnB/Semestre8/PVC/Projetos/ProjetoFinal/cvpr16-deepbit/models/deepbit/deploy32.prototxt';

caffe.set_mode_gpu();
caffe.set_device(0);
net = caffe.Net(model_def_file, model_file, 'test');
net.blobs('data').reshape([224 224 3 1]); % reshape blob 'data'

mediaBin = 0; % media que vai ser usada para a binarizacao dos atributos extraidos pelo deepbit

todasImagens = '/home/victor/UnB/Semestre8/PVC/Projetos/ProjetoFinal/Imagens/todasimagens.txt';
listaImagens = read_cell(todasImagens);

%% Extracao dos descritores binarios para todas as imagens e calculo da media mean_th

numImagens = length(listaImagens);

% Loop que vai ler as imagens da lista de imagens e fazer as operacoes
% necessarias

resultDeepBit = zeros(numImagens, 32);
firstTime = 0;
% Se for a primeira vez que esta rodando, faz todo o procedimento, se nao for,
% ja carrega o objeto mat
if(firstTime == 1)
    % Para cada imagem, vai rodar o modelo deepbit e vai adicinar o resultado
    % em um vetor coluna, de modo que vai ficar 4900x32
    for i = 1:numImagens
        im = imread(listaImagens{i});
        im = imresize(im, [224, 224]);
        resultModel = net.forward({im});
        resultDeepBit(i, :) = resultModel{1, 1};
    end
    feat_result_file = sprintf('%s/resultDeepBit.mat', '.');
    save(feat_result_file);
else
    load('./resultDeepBit.mat');
end

% Calcula a media de cada coluna
mediaCol = mean(resultDeepBit);
% Calcula o resultado da media de cada coluna, ou seja, calcula agora a
% media geral
mediaBin = mean(mediaCol);


% Avalia os features originais de cada img, se for maior que a media geral
% vira 1, senao 0
% binarioImagens = (resultDeepBit > mediaBin);
