# learning_postgresql
sudo service postgresql start;
sudo su postgres;

time for ((i=0;i<500;i++));  
 do  
   psql -f /tmp/snake.sql;  
 done|grep "{"|sort|uniq|sed -re 's/\{|\}|\(|\)//g'; 

real	0m28.188s

 1,2,3,6,5,4,7,8,9  
 1,2,5,4,7,8,9,6,3  
 1,4,7,8,9,6,3,2,5  
 1,4,7,8,9,6,5,2,3  
 3,2,1,4,7,8,9,6,5  
 3,6,5,2,1,4,7,8,9  
 5,2,1,4,7,8,9,6,3  
 5,4,7,8,9,6,3,2,1  
 5,6,3,2,1,4,7,8,9  
 5,8,9,6,3,2,1,4,7  
 7,4,1,2,3,6,5,8,9  
 7,4,1,2,5,8,9,6,3  
 7,4,5,8,9,6,3,2,1  
 7,8,9,6,3,2,1,4,5  
 7,8,9,6,3,2,5,4,1  
 7,8,9,6,5,4,1,2,3  
 9,6,3,2,1,4,5,8,7  
 9,6,3,2,1,4,7,8,5  
 9,6,3,2,5,8,7,4,1  
 9,6,5,8,7,4,1,2,3  
 9,8,5,6,3,2,1,4,7  
 9,8,7,4,1,2,3,6,5  
 9,8,7,4,1,2,5,6,3  
 9,8,7,4,5,6,3,2,1  
