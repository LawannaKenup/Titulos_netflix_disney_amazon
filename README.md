<h1 align="center"> Títulos Netflix Disney e Amazon </h1>

<h4 align="center">Exercício desenvolvido em SQL, contendo uma exploração dos dados de 3 tabelas contendo títulos da Netflix, Disney Plus e Amazon Prime.</h4>

<h2 align="center"><img src="https://img.shields.io/static/v1?label=STATUS&message=CONCLUIDO&color=green&style=for-the-badge"/></h2>

<img src="https://img.shields.io/static/v1?label=Language&message=SQL&color=blue"/> 

 <h2>:gear: Acesso ao Projeto</h2>
 
- Para acessar o projeto, basta clonar o repositório.

<h3> 📝 Dataset utilizado: </h3>

 - Encontram-se na pasta dados todos os datasets utilizados no exercício.

<h3> :teacher: Enunciado: </h3>

- Somos uma empresa de Streaming que conseguiu um contrato para retransmitir dos nossos parceiros netflix, disney_plus e amazon_prime os seus conteúdos. A equipe de dados solicitou ao time diversas entregas que precisam ser realizadas para os ajustes na base assim como as regras de negócio.

<h3> 📝 Questões a serem resolvidas: </h3>

1. Unifique as bases de dados do netflix, disney_plus e amazon_prime. Escolha uma das duas opções abaixo.

 - 1 Opção mude o campo show_id das respectivas bases de modo que não tenhamos repeticao nos ids.

-  2 Opção voce pode construir uma nova coluna que represente o ID do tabelao. 

2. Normalize as colunas do tabelão:

- cast, country, listed_in, date_added, duration;

3. Faça um diagrama de relacionamento (DER) das novas tabelas criadas

4. Preencha os campos em branco com 'Null'.


<h4 align="center">Questões de negócios:</h4>


5. Informe qual a série tem tempo de duração somados de 30 horas ou mais.

6. A equipe precisa seguimentar o tempo de tela de cada conteúdo de filmes, dessa forma, 
crie uma coluna que tenha a informação particionada pela categoria e descubra o tempo máximo em horas de cada segmento.

7. Crie uma nova coluna de classifição dos conteúdos por estrelas pelos seguintes critérios.

- 1. O conteúdo precisa ter no mínimo 120 minutos. =  uma estrela.
- 2. A produção ser americana. =  uma estrela. 
- 3. A produção ser francesa. = uma estrela.
- 4. A quantidade do elenco precisa ser igual ou maior que 3. = uma estrela 
- 5. O número dos diretores precisa ser igual a 1 ou 2. = uma estrela 


8. Construa uma coluna que possua o rank dos melhores filmes pelos critérios da questao 7.

9. Construa uma coluna que possua o rank das melhores séries pelos critérios da questao 7.

10. Desafio. 

O nosso sistema desenvolveu uma campanha de publicidade no qual o cliente digita na busca dos conteúdos
a sua data de aniversário (DDMM) e o sistema retorna a sugestão de filmes que foram adicionados no sistema naquela
data. 

- Faca uma funcao ao qual recebe uma inteiro que correspode ao dia e mes e retorna 1 uma sugestao de filme aos quais o dia e mes
de publicacao na plataforma dao match. Gere o campo sugestao_1

- Alem disso, a classificão de conteúdo precisa ser maior ou igual a 3 estrelas.

- Caso o cliente nao goste da sugestão ele pode ter como retorno a sugestão anterior a essa. Gere o campo sugestao_2.
