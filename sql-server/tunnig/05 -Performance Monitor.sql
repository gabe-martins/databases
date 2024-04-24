 /*
Performance Monitor 

- Ferramenta do Windows que visualiza as estat�sticas de contadores de objetos em tempo real do 
  computador local ou de um computador remoto. 

- Os objetos podem pertencer ao Sistema Operacional como Disco ou Interface de rede
  ou de um software como o SQL Server. 

Algumas caracater�sticas.

- Exibe os dados no formato gr�fico em linha ao longo do tempo.
- Exibe os dados em formato barra ou texto em tempo real.
- Permite definir o intervalo de captura.
- Salva os dados em arquivo texto
- Permite a leitura de dados gravados.

** Demonstrar o acesso a ferramenta.

Objetos de Desempenho
--------------------- 

S�o containers que agrupa grupos de contadores de desempenho. 

Exemplos

Object:Processor - Cont�m contadores de atividades do processador como % de uso da CPU
Object:Network Interface - Cont�m contadores de taxas que os bytes s�o enviados e recebidos
                           pela interface de rede.
Object:Physical Disk - Cont�m contadores que monitora os discos f�sicos, como percentual de utiliza��o
                       bytes lidos e gravados e a tamanho da fila de disco.

Contadores
----------

Cada objeto cont�m um conjunto de contadores com valores absolutos ou percentuais. Esses valores
podem ser utilizados com base em valores padr�es para indicar a performance do ambientes.

Exemplo

O objeto Object:Physical Disk, cont�m o contador 'Avg. Disk Queue Length' que cont�m
o tamanho m�dio de solicita��es de leitura e grava��o enfileiradas para o disco 
selecionado durante o intervalo de amostra.

Esse contador com valor alto, pode significar garg�los em discos. Valores acima de 2,
por exemplo, pode se um indicativos de baixa performance.

Objetos de Desempenho para SQL Server 
-------------------------------------

Quando instalamos o servi�o do SQL Server, a instala��o tamb�m realiza
a instala��o de contadores para o gerenciador de banco de dados.

Para a vers�o do SQL SERVER 2017, temos 38 objetos de desempenho com 1911 contadores.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/performance-monitor/use-sql-server-objects?view=sql-server-2017

Exemplo:

Objeto
-------
Gerenciador de Buffer (SQLServer:Buffer Manager) 
   - Mem�ria para armazenar p�ginas de dados.
   - Contadores para monitorar a E/S f�sica, como leituras e grava��es 
     das p�ginas do banco de dados do SQL Server .
   - Monitorar a mem�ria e os contadores usados pelo SQL Server ajuda a determinar:
   - Se existem gargalos devidos � mem�ria f�sica inadequada. Caso n�o consiga 
     armazenar em cache os dados acessados com frequ�ncia, o SQL Server ter� que recuper�-los do disco.
   - Se o desempenho das consultas pode ser melhorado pela adi��o de mem�ria ou 
     pela disponibiliza��o de mais mem�ria para cache de dados ou para as estruturas internas do SQL Server .
   - A frequ�ncia com que o SQL Server precisa ler dados a partir do disco. 
     Comparada com outras opera��es, como acesso de mem�ria, a E/S f�sica 
     demora muito mais. Minimizar a E/S f�sica pode melhorar o desempenho de consulta.


Contadores 
------------

P�ginas do banco de dados  (SQLServer:Buffer Manager -> Database Pages)

- Indica o n�mero de p�ginas no pool de buffers do n� com conte�do de banco de dados.

Leituras de p�gina/seg   (SQLServer:Buffer Manager -> Page Reads/S)

- Indica o n�mero de leituras de p�gina de banco de dados f�sica emitidas por segundo. 
  Essa estat�stica exibe o n�mero total de leituras de p�gina f�sica em todos os 
  bancos de dados. Como a E/S f�sica � dispendiosa, conv�m minimizar o custo 
  utilizando um maior cache de dados, �ndices inteligentes e consultas mais 
  eficientes ou alterando o design do banco de dados.


Demonstra��o


*/




/*
DMV  - sys.dm_os_performance_counters.

Apresenta os contadores de desempenho do SQL Server e que s�o
utilizados no Performance Monitor



Ref: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql?view=sql-server-2017*/


Select * from  sys.dm_os_performance_counters

Select * from  sys.dm_os_performance_counters
where object_name = 'SQLServer:Buffer Manager'
   and counter_name in ('Page reads/sec','Database pages')


/*
Capturando os dados em uma tabela para posterior an�lise 
*/

use tempdb 
go
drop Table #tPerformanceCounter
go

Create Table #tPerformanceCounter (
   iID int identity(1,1) primary key, 
   cObject char(40),
   cCounter char(40),
   nValue int ,
   dStarted datetime2(2) default getdate()
)

Truncate table #tPerformanceCounter 
go

Insert #tPerformanceCounter (cObject,cCounter,nValue)
Select object_name, counter_name , cntr_value
  From sys.dm_os_performance_counters
 Where object_name = 'SQLServer:Buffer Manager'
   and counter_name in ('Page reads/sec','Database pages')
waitfor delay '00:00:01'
go 100


Select * 
  From #tPerformanceCounter
 Where cCounter = 'Database pages'


select count(1) from sys.dm_os_buffer_descriptors


Select * 
  From #tPerformanceCounter
 Where cCounter = 'Page reads/sec'
 order by dStarted

/*
O contador 'Page reads/sec' 
*/

/*
Para SQL Server 2012 em diante 
*/
Select iid , 
       cObject, 
       cCounter, 
       nValue - LAG(nValue) over (order by iid) as nValue, 
       dStarted 
  From #tPerformanceCounter
 Where cCounter = 'Page reads/sec'
 

/*
Para SQL Server 2008 e 2008 R2
*/
 ;
 with ctePageReads as (
    Select ROW_NUMBER() over (order by iid) as iid , cObject, cCounter, nValue, dStarted 
     From #tPerformanceCounter
    Where cCounter = 'Page reads/sec'
 )
 select PRDepois.iid , PRDepois.cObject, PRDepois.cCounter,  PRDepois.nValue - PRAntes.nvalue , PRDepois.dStarted
   from ctePageReads PRAntes
   join ctePageReads PRDepois
     on PRAntes.iID+1 = PRDepois.iID

