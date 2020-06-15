#!/usr/bin/perl
use strict;
use utf8;
use Encode;
#Cистемные
use Cwd;
use Data::Dumper;
use HTTP::Date;
#Дополнительные
use Spreadsheet::WriteExcel;

#Функции для работы с временем
#Исправление месяца
#Парс из YYYY.MM.DD в unix timestamp
sub date2Time{
    my $dd  = $_[0];
    my $mm  = $_[1];
    my $yy  = $_[2];
    my $date = sprintf("%04d-%02d-%02d",($yy + 1900) , ($mm + 1),$dd);
    return HTTP::Date::str2time($date);
}

#Сопоставление IP-адрес => Имя Филиала
my %branchesIp = (
    '176.59.49.93'      => 'Филиал Балашиха',
    '93.171.33.47'      => 'Филиал Видное',
    '95.154.152.153'    => 'Филиал Воскресенск',
    '95.66.149.7'       => 'Филиал Владимир',
    '176.114.225.230'   => 'Филиал Голицыно',
    '87.236.29.62'      => 'Филиал Дмитров',
    '81.5.111.122'      => 'Филиал Долгопрудный',
    '149.126.96.242'    => 'Филиал Домодедово',
    '185.48.37.62'      => 'Филиал Дубна',
    '193.233.158.157'   => 'Филиал Зеленоград',
    '91.192.21.4'       => 'Филиал Истра',
    '178.76.204.31'     => 'Филиал Калуга',
    '178.218.18.77'     => 'Филиал Клин',
    '91.226.166.30'     => 'Филиал Коломна',
    '185.138.206.5'     => 'Филиал Королев',
    '193.169.45.54'     => 'Филиал Красногорск',
    '185.134.233.33'    => 'Филиал Краснодар',
    '158.255.80.30'     => 'Филиал Люберцы',
    '94.253.42.3'       => 'Филиал Можайск',
    '89.175.157.38'     => 'Филиал Москва',
    '213.167.57.230'    => 'Филиал Москва 2',
    '94.159.38.118'     => 'Филиал Москва 3',
    '213.171.46.140'    => 'Филиал Москва 4',
    '81.23.3.102'       => 'Филиал Москва 5',
    '46.183.182.30'     => 'Филиал Мытищи',
    '212.67.18.41'      => 'Филиал Нижний Н.',
    '109.95.77.193'     => 'Филиал Наро-Фоминск',
    '178.216.161.202'   => 'Филиал Ногинск',
    '195.112.102.62'    => 'Филиал Обнинск',
    '188.130.154.195'   => 'Филиал Одинцово',
    '176.101.56.133'    => 'Филиал Подольск',
    '93.188.188.3'      => 'Филиал Раменское',
    '176.118.218.217'   => 'Филиал Рязань2',
    '217.197.244.28'    => 'Филиал Сергиев Посад',
    '62.176.15.171'     => 'Филиал Серпухов',
    '93.179.94.211'     => 'Филиал Ступино',
    '176.114.202.65'    => 'Филиал Тверь',
    '212.41.38.98'      => 'Филиал Троицк',
    '5.164.27.163'      => 'Филиал Тула',
    '109.68.16.128'     => 'Филиал Химки',
    '194.1.161.24'      => 'Филиал Чехов',
    '80.76.109.109'     => 'Филиал Шаховская',
    '46.160.232.191'    => 'Филиал Щелково',
    '149.126.96.242'    => 'ЦД'
);

my @branches;

foreach my $ip(sort{$branchesIp{$a} cmp $branchesIp{$b}}keys %branchesIp){
    push @branches => $ip;
}

#Получение пути и генерация имени файла
 my $PATH = getcwd() . "/";
 my $FILE_NAME = "Cписок посещений" . localtime(time) . '.xls';
 my $FILE_PATH = "$PATH $FILE_NAME";

 #####Excel::Writer#####
 #Создание файла
 my $workbook = Spreadsheet::WriteExcel->new($FILE_PATH);

 #Формат вывода дат
 my $dateformat = $workbook->add_format();
 $dateformat -> set_bold();
 #$dateformat -> set_color( 'red' );
 $dateformat -> set_align( 'center' );

 #Формат вывода адресов/филиалов
 my $brenchformat = $workbook->add_format();
 $brenchformat -> set_bold();
 #$format -> set_color( 'red' );
 $brenchformat -> set_align( 'left' );
 $brenchformat -> set_size(12);

 #Добавление страницы Кол-во обращений Филиал X День
 my $worksheet = $workbook->add_worksheet('Кол-во обращений Филиал X День');

####::MAIN::#####################################################################################################
#Чтение входного файла обращений
my @fileTextByLine = ();
my $file = '/home/redfraction/Desktop/_Perl/iteract with files/_testFiles/index.txt';
open my $info, $file or die "Could not open $file: $!";

if ( open my $inputStream , "/home/redfraction/Desktop/_Perl/iteract with files/MS Office/" . "request.list" ) {
	@fileTextByLine = <$inputStream>;
	close $inputStream if $inputStream;
}

#Разбивка текста
my %hash;
my %timestampPerDate;

# print "Кол-во записей: $#fileTextByLine\n"; #--------------remove

for (my $i = 0; $i < $#fileTextByLine; $i++){

    my ($ip, $unixTime) = split(/\|/, $fileTextByLine[$i]);                         # (255.255.255.255 ,unixTime)
    my ($sec,$min,$hour,$dd,$mm,$yyyy) = localtime($unixTime);                      # 00:00:00 dd.mm.yyyy

    my $ddmmyyyy     = sprintf("%02d.%02d.%04d",$dd , ($mm + 1),($yyyy + 1900));    # yyyy.mm.dd / 16.03.2020
    my $nullTimeDate = date2Time($dd, $mm + 1, $yyyy + 1900);                       # unix timestamp with annulled hour, min and seconds

    if ($branchesIp{$ip}){
        $hash{$ip}{$nullTimeDate}++;
        $timestampPerDate{$nullTimeDate} = $ddmmyyyy;
    }
}

{
    #Вывод дат
    my $rowItr = 0; # Установка начальной 
    my $colItr = 1; # ячейки B1

    foreach my $i (sort {$a <=> $b} keys %timestampPerDate){
        $worksheet->write($rowItr, $colItr++, $timestampPerDate{$i}, $dateformat);
    }

    #Вывод Филиалов
    $rowItr = 1; # Установка начальной ячейки
    $colItr = 0; # ячейки A1

    foreach my $i (sort {$a cmp $b} values %branchesIp){
        $worksheet->write($rowItr++, $colItr, $i, $brenchformat);
    }
     
    $rowItr = 1;
    $colItr = 1;
    
    foreach my $ip (@branches){
        foreach my $date (sort {$a <=> $b} keys %timestampPerDate){
            my $count = int (exists $hash{$ip}{$date} ? $hash{$ip}{$date} : undef);
            if ($count) {
                $worksheet->write($rowItr, $colItr, $count);
                #print $rowItr . '/' . $colItr . "\n";
            }
            $colItr++
        }
        
        $rowItr++;
        $colItr = 1;
    }
    $workbook->close();
}

#Вывод филиалов
#print Dumper \%hash;


