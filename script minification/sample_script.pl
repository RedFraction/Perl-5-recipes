#!/usr/bin/perl
package sitemodules::Branch;

our $VERSION = 2.1;
use strict;
use utf8;
use JSON;

use sitemodules::CGI;
use sitemodules::Debug;
use sitemodules::ModSet;
use sitemodules::Settings;
use sitemodules::JCarousel;
use sitemodules::Constants qw/CONTACT_MASTER_PAGE_ID/;

sub new {
	my $class = shift;
    my $self = bless {@_}, $class;
	return $self
}

sub info {
	
	my $class 			= shift;
	my %params 			= !(@_ % 2) ? @_ : ();
	my $branchID 		= int $params{ 'branchID' };
	my $mobile 			= $ENV{ 'HTTP_MOBILE' };
	my $mobile_css		= $mobile ? 'mobile' : undef;
	my $map_width 		= $mobile ? '100%' : '450px';
	my $map_height 		= '400px';
	my $dt 				= !$mobile ? '-dt' : undef; # desktop flag
	my @out;
	
	if ( $branchID ) {
		
		my $branch_mode_id = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT ID FROM branch_mode_tbl WHERE current_fld = 'Y'") || -1;
		my $htdocs = $sitemodules::Settings::c{ 'dir' }{ 'htdocs' };
		
		my $branch = $sitemodules::DBfunctions::dbh->selectrow_hashref("SELECT * FROM branch_tbl WHERE branch_id = $branchID") || {};
		if ( $branch->{ 'branch_id' } > 0  ) {

			### телефоны new (с добавочными)
			my (%phone, @phone_out);
			my $sth10 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM branch_phone_tbl WHERE branch_id = $branchID");
			$sth10->execute();
			while (my $r = $sth10->fetchrow_hashref) {
				my $pID = $r->{ 'branch_phone_id' };
				$phone{ $pID } = $r;
			}

			### телефоны
			if (keys %phone) {

				###
				my (@phone);

				foreach my $bpID (sort {
					$phone{ $a }{ 'order_fld' } <=> $phone{ $b }{ 'order_fld' }
						or
						$phone{ $a }{ 'phone_fld' } cmp $phone{ $b }{ 'phone_fld' }
				} keys %phone) {

					my @tel = $phone{ $bpID }{ 'phone_fld' };
					(my $tel_int = $tel[0]) =~ s!\D+!!g;
					(my $tel_seven = $tel_int) =~ s!^8!7!;

					### добавочный
					my $add = $phone{ $bpID }{ 'add_fld' };
					push @tel => "~$add";

					### иконки
					my @icons;

					if ($phone{ $bpID }{ 'viber_fld' }) {
						push @icons => $mobile ? qq[<a href="viber://add?number=$tel_seven"><span class="viber"></span></a>] : qq[<span class="viber"></span>];
					}
					if ($phone{ $bpID }{ 'whatsapp_fld' }) {
						push @icons => $mobile ? qq[<a href="whatsapp://send?phone=+$tel_seven"><span class="whatsapp"></span></a>] : qq[<span class="whatsapp"></span>];
					}

					push @tel => qq[~@icons];
					push @phone => qq[@tel];

				}

				my @pa;
				if (@phone > 0) {
					foreach my $tel (@phone) {

						my @tel = split /\~/ => $tel;
						(my $tel_int = $tel[0]) =~ s!\D+!!g;
						next unless $tel_int;

						my $add_num_str;
						if ($tel[1] > 0) {
							$add_num_str = qq[ доб. $tel[1]];
						}

						my $icons = $tel[2];
						push @pa => qq[<div><a href="tel:$tel_int" class="link$dt inline">$tel[0]</a>$add_num_str $icons </div>];
					}
				}

				my $call_back_form = !$mobile ? qq[<div><a href="javascript:void(call_back_form())" class="link">Заказать звонок</a></div>] : undef;
				push @phone_out => qq[<div class="item">
					<div class="bold">Телефоны:</div>
					<div>@pa</div>
					$call_back_form
				</div>];

			}

			### сотрудники
			my (%workers, @workers_out);
			my $sth12 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM branch_user_tbl WHERE branch_id = $branchID");
			$sth12->execute();
			while (my $r = $sth12->fetchrow_hashref) {
				my $pID = $r->{ 'branch_user_id' };
				$workers{ $pID } = $r;
			}

			if (keys %workers) {

				push @workers_out => qq[
					<div class="item">
						<div class="bold">Сотрудники офиса:</div>
						<div class="tab vtop staff">];

				my $is_phones = 0;
				#my $is_skype = 0;
				my @rows;

				foreach my $wID (sort {$workers{ $a }{ 'order_fld' } <=> $workers{ $b }{ 'order_fld' } or $a <=> $b} keys %workers) {

					### телефоны (с добавочными)
					my %user_phone;
					my @user_phone;
					my %orig_number;
					my %user_phone_data;
					my %user_phone_order;
					my (%viber, %whatsapp);

					my $sth20 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM branch_user_phone_tbl WHERE branch_user_id = $wID");
					$sth20->execute();
					while (my $r = $sth20->fetchrow_hashref) {

						(my $pID = $r->{ 'phone_fld' }) =~ s!\D+!!g;

						$user_phone{ $pID }{ $r->{ 'add_fld' } }++;
						$orig_number{ $pID } = $r->{ 'phone_fld' };
						$user_phone_order{ $pID } = $r->{ 'order_fld' };
						$user_phone_data{ $pID }{ $r->{ 'add_fld' } }++ if $r->{ 'add_fld' };
						$viber{ $pID }++ if $r->{ 'viber_fld' };
						$whatsapp{ $pID }++ if $r->{ 'whatsapp_fld' };

					}

					foreach my $uph (sort {$user_phone_order{ $a } <=> $user_phone_order{ $b } or $a <=> $b} keys %user_phone) {

						push @user_phone => qq[<div class="link">];

						my $num_url = qq[tel:$uph];
						my $num_label = $orig_number{ $uph };
						my $add_num_str;

						if ($user_phone_data{ $uph }) {
							my @_add;
							foreach my $_add (sort {$a <=> $b} keys %{$user_phone_data{ $uph } || {}}) {
								push @_add => $_add;
							}
							$add_num_str = ' доб. ' . join ', ' => @_add;
						}

						### иконки
						my @icons2;
						(my $tel_seven = $uph) =~ s!^8!7!;

						if ($viber{ $uph }) {
							push @icons2 => $mobile ? qq[<a href="viber://add?number=$tel_seven"><span class="viber"></span></a>] : qq[<span class="viber"></span>];
						}
						if ($whatsapp{ $uph }) {
							push @icons2 => $mobile ? qq[<a href="whatsapp://send?phone=+$tel_seven"><span class="whatsapp"></span></a>] : qq[<span class="whatsapp"></span>];
						}

						my $icons2 = qq[@icons2];

						push @user_phone => qq[<a href="$num_url" class="link$dt">$num_label</a>$add_num_str $icons2];
						push @user_phone => qq[</div>];
					}

					$is_phones += scalar @user_phone;

					push @rows => qq[<div class="row">
					<div class="cell l">$workers{ $wID }{ 'fio_fld' }</div>
					<div class="cell r">@user_phone</div>
					</div>];

				}

				push @workers_out => qq[@rows];
				push @workers_out => qq[</div>]; # div.tab vtop staff
				push @workers_out => qq[</div>]; # div.item

			}

			### адрес
			my @address_out;
			if ($branch->{ 'address_fld' }) {
				push @address_out => qq[<div class="item">
					<div class="bold">Адрес:</div>
					<div>$branch->{ 'address_fld' }</div>
				</div>];
			}

			### e-mail
			my @email_out;
			if ($branch->{ 'email_fld' }) {

				my @e = split /\r?\n/ => $branch->{ 'email_fld' };
				my @ea;

				foreach my $e (@e) {
					push @ea => qq[<div><a href="mailto:$e" class="link">$e</a></div>];
				}

				push @email_out => qq[<div class="item">
					<div class="bold">E-mail:</div>
					<div>@ea</div>
				</div>] if scalar @ea > 0;
			}

			### режим работы
			my (
				$worktime_fld,
				$call_time_from_fld,
				$call_time_to_fld
			) = $sitemodules::DBfunctions::dbh->selectrow_array("
				SELECT
					wt.worktime_fld,
					wt.call_time_from_fld,
					wt.call_time_to_fld
				FROM
					branch_worktime_tbl wt, branch_worktime_branch_tbl bwt
				WHERE
					wt.ID = bwt.branch_worktimeID
					AND bwt.branch_id = $branchID
					AND wt.branch_mode_id = $branch_mode_id
			");

			my @worktime_out;

			if ($worktime_fld) {
				push @worktime_out => qq[<div class="item">
					<div class="bold">Режим работы:</div>
					<div>$worktime_fld</div>
				</div>];
			}

			my @ymap;

			#Получение
			my $branch_data = $class->get_branch_data(branchIDs => $branchID);	# Текущий филиал
			my $other_data	= $class->get_branch_data( %params );	#Остальные филиалы

			my @branch_order =  @{ $other_data->{ 'order' } };

			# Вставляем текущий филиал в начало
			foreach ( @{ $branch_data->{ 'order' } } ){
				unshift @branch_order, $_;
			}

			$other_data->{ 'js_data' }{ "$branchID" }{ 'red' } = 1; # Выделение красным

			my $js_data = JSON::to_json( $other_data->{ 'js_data' } || '{}' );
			my $order 	= JSON::to_json( \@branch_order 			|| '[]' );
			my $nav 	= JSON::to_json( $other_data->{ 'nav' } 	|| '{}' );

			my $lt = $branch_data->{ 'js_data' }{ $branchID }{ 'lat' };
			my $ln = $branch_data->{ 'js_data' }{ $branchID }{ 'lng' };

			if ( $lt && $ln ) {

				# Кнопка открыть в яндекс навигаторе
				my $navi_btn = $mobile ? qq[
					<a class="navi-btn link" href="yandexnavi://build_route_on_map?lat_to=$lt&lon_to=$ln">
						Открыть в "Яндекс.Навигатор"
						<img src="/css/3.0/images/yanavi-logo.svg" class="ya-navi-img">
					</a>
				] : '';

				# По умолчанию вывод версии для десктопа (Если не мобильная)
				my $coords = '<script src="/js/copy2clipboard.js"></script>
					<div class="geo-in"><b>Координаты:</b></div>' . (!$mobile ? qq[
					<div class="geo-in" id="coordinates">$lt $ln</div>
					<a href="javascript:void(0)" class="geo-in geo-copy-bt" title="Копировать" onclick="CopyToClipboard('coordinates')">
						<img src="/css/3.0/images/copy-icon.svg" width="24" height="24"/>
					</a>
				]
					: # Если мобильная версия
				qq[
					<div class="geo-in">
						<a class="geo" href="geo:$lt,$ln?q=$lt,$ln">
							<div class="text" id="coordinates">$lt $ln</div>
						</a>
					</div>
					<button class="geo-in geo-copy-bt" onclick="CopyToClipboard('coordinates')">
							<img src="/css/3.0/images/copy-icon.svg" width="24" height="24"/>
					</button>
				]);

				@ymap = ( $mobile ? '' : $coords ) . qq[
					<div class="ymap" id="YMapsID" style="width: $map_width; height: $map_height; overflow:hidden;"></div>
					<script type="text/javascript">
						var coords = $js_data;
						var coords_order = $order;
						var coords_nav = $nav;
					</script>
					<script src="https://api-maps.yandex.ru/2.0-stable/?load=package.full&lang=ru-RU" type="text/javascript"></script>
					<script type="text/javascript" src="/js/map-branch-item.js?22.03.2017"></script>
				] . ( $mobile ? "$coords $navi_btn" : '' ) ;
			}
			
			### левая ячейка - реквизиты филиала. правая ячейка - карта
			push @out => qq[<div class="tab branch-tab-level1 w100per $mobile_css">
				<div class="row">
					<div class="cell txt vtop">
						@address_out
						@worktime_out
						@email_out
						@phone_out
						@workers_out
					</div>
					<div class="cell map vtop">
						@ymap
					</div>
				</div>
			</div>];
			
			### фото
			my @bigs = map { $_->[0] } @{ $sitemodules::DBfunctions::dbh->selectall_arrayref("SELECT foto_fld FROM branch_gallery_tbl WHERE branch_id = $branchID ORDER BY order_fld") || [] };
			my $JC = new sitemodules::JCarousel;
			my @items = $JC->draw_items( bigs => \@bigs , query => "branchID=$branchID" );
			push @out => $JC->init( items => \@items );
	
		}
	}
	return qq[@out];
	
}

sub get_branch_data {
	
	my $class 				= shift;
	my %params 				= !(@_ % 2) ? @_ : ();
	my $mobile 				= $ENV{ 'HTTP_MOBILE' };
	my $data 				= {};
	$data->{ 'js_data' } 	= {};
	my $CMPID				= CONTACT_MASTER_PAGE_ID;
	my $dbh 				= $sitemodules::DBfunctions::dbh;
	my @branchIDs			= ref $params{ 'branchIDs' } eq 'ARRAY' ? @{ $params{ 'branchIDs' } } : ( int $params{ 'branchIDs' } ? $params{ 'branchIDs' } : () );
	my $where;
	if ( @branchIDs > 0 ) {
		$where = " AND branch_id IN(" . ( join ',' => @branchIDs ) .")";
	}

	### порядок филиалов по дереву страниц (раздел контакты) + связь страницы и филиала
	my ( %nav , @order , %branchIDs , %url );
	grep {
		
		my $mID = $_->[0]; # оригинал, к которому привязан филиал
		my $sID = $_->[1]; # ссылка
		my $bID = $_->[6]; # ID филиала
		push @order => $sID;
		$branchIDs{ $bID }++;
		$url{ $mID } = $nav{ $sID }{ 'url' } = $_->[5] || $_->[2];
		$nav{ $sID }{ 'label' } = $_->[3];
		$nav{ $sID }{ 'branchID' } = $bID;
		
	} @{ $dbh->selectall_arrayref("
		SELECT
			m.page_id, 		#0
			s.page_id, 		#1
			s.url_fld, 		#2
			s.label_fld, 	#3
			s.order_fld, 	#4
			s.alias_fld, 	#5
			b.branch_id		#6
		FROM
			branch_tbl b,
			page_tbl m LEFT OUTER JOIN page_tbl s ON m.url_fld = s.url_fld
		WHERE
			m.enabled_fld = '1'
			AND m.master_page_id IN ($CMPID)
			AND m.page_id = b.page_id
			$where
		GROUP BY s.page_id
		ORDER BY s.order_fld
	") };
	
	$data->{ 'order' } = \@order;
	$data->{ 'nav' } = \%nav;
	
	### получаем данные филилалов
	my $branchIDstr = join ',' => keys %branchIDs;
	if ( $branchIDstr ) {

		my $branch_mode_id = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT ID FROM branch_mode_tbl WHERE current_fld = 'Y'") || -1;
		
		### получение данных филиалов
		my $sth = $dbh->prepare("
							SELECT
								*
							FROM
								branch_tbl b
							WHERE
								branch_id IN($branchIDstr)
							");
		$sth->execute();
		my %data;
		while ( my $r = $sth->fetchrow_hashref ) {
			$data{ $r->{ 'branch_id' } } = $r;
		}
		
		### режимы работы по режиму
		my $sth = $dbh->prepare("
								SELECT
									wt.worktime_fld,
									wt.call_time_from_fld,
									wt.call_time_to_fld,
									bwt.branch_id
								FROM
									branch_worktime_tbl wt, branch_worktime_branch_tbl bwt
								WHERE
									wt.ID = bwt.branch_worktimeID
									AND bwt.branch_id IN($branchIDstr)
									AND wt.branch_mode_id = $branch_mode_id
								");
		$sth->execute();
		my %wt;
		while ( my $r = $sth->fetchrow_hashref ) {
			$wt{ $r->{ 'branch_id' } } = $r;
		}

		if ( keys %data ) {
			
			### фото филиалов, первые в галерее
			my %foto;
			my $sth_f = $dbh->prepare("SELECT branch_id,foto_fld FROM branch_gallery_tbl GROUP BY branch_id,order_fld HAVING order_fld IN(0)");
			$sth_f->execute();
			while ( my $r = $sth_f->fetchrow_hashref ) {
				$foto{ $r->{ 'branch_id' } } = $r->{ 'foto_fld' };
			}
			
			foreach my $id ( keys %data ) {
				
				my $r = $data{ $id } || {};
				my $label = $r->{ 'branch_fld' };
				my $lat = $r->{ 'lat_fld' };
				my $lng = $r->{ 'lng_fld' };
				
				### телефоны new (с добавочными)
				my %phone;
				
				my $sth10 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM branch_phone_tbl WHERE branch_id = $id");
				$sth10->execute();
				while ( my $r = $sth10->fetchrow_hashref ) {
					
					my $pID = $r->{ 'branch_phone_id' };
					$phone{ $pID } = $r;
					
				}
				
				my @phone; # все телефоны
				my @phone_static; # городские телефоны
				
				### номера филиалов из таблицы branch_phone_tbl
				if ( keys %phone ) {
					foreach my $bpID (keys %phone) {

						my @tel = $phone{ $bpID }{ 'phone_fld' };
						push @tel => "~" . $phone{ $bpID }{ 'add_fld' };

						### иконки
						my @icons;

						if ($phone{ $bpID }{ 'viber_fld' }) {
							push @icons => qq[<span class="viber"></span>];
						}
						if ($phone{ $bpID }{ 'whatsapp_fld' }) {
							push @icons => qq[<span class="whatsapp"></span>];
						}

						push @tel => qq[~@icons];
						push @phone => qq[@tel];

						if ( $phone{ $bpID }{ 'static_fld' } ) {
							push @phone_static => qq[@tel];
						}
					}
				}
				
				my @addr = split /\r?\n/ => $r->{ 'address_fld' };
				my @email = split /\r?\n/ => $r->{ 'email_fld' };
				grep { $_ = qq[<a href="mailto:$_" class="link">$_</a>]; } @email;
				
				foreach ( @phone ){
					
					my @_phone = split /\~/ => $_;
					my $_add_num_str;
					if ( $_phone[1] > 0 ) {
						$_add_num_str = qq[ доб. $_phone[1]];
					}
					$_ = qq[<span class="inline phone">$_phone[0]</span> $_add_num_str $_phone[2]];
					
				}
				
				### режим работы
				my $worktime_fld = $wt{ $id }{ 'worktime_fld' };
				
				my $addr = (join '<br/>' => @addr);
				my $phone = (join '<span class="br"></span>' => sort { $a cmp $b } @phone);
				my $email = join ', ' => @email;
				
				@phone_static = sort { $a cmp $b } @phone_static;
				
				my @static = split /\~/ => $phone_static[0];
				(my $tel_int = $static[0]) =~ s!\D+!!g;
				my $add_num_str;
				if ( $static[1] > 0 ) {
					$add_num_str = qq[ доб. $static[1]];
				}
				
				my $page_id = int $r->{ 'page_id' };
				my $url = $url{ $page_id };
				
				my $href = $url ? qq[<a href="$url">$label</a>] : qq[<a href="javascript:void(show_branch('$id'))">$label</a>];
				my $tel_href;
				
				if ( $mobile ) {
					$tel_href = $tel_int > 0 ? qq[<a href="tel:$tel_int" class="link">$static[0]</a>$add_num_str] : $static[0];
				} elsif ($url) {
					$tel_href = qq[<a href="$url" class="link">$static[0]</a>$add_num_str];
				} else {
					$tel_href = $static[0];
				}
		
				my @body = qq[<h3 class="balloon-head">$label</h3>
				<div class="addr map-b">$addr</div>
				<div class="phone map-b branch$id">$phone</div>
				<!--div class="addr map-b">$worktime_fld</div-->
				<div class="map-b"><a href="$url" class="link">Подробнее ></a></div>];
		
				if ( $lat > 0 && $lng > 0 ){
					
					my $small = $foto{ $id } ? $class->do_small_name( foto => $foto{ $id } ) : 'null'; 
					
					$data->{ 'js_data' }{ $id } = {
						lat => $lat,
						lng => $lng,
						label => $label,
						body => qq[@body],
						id => $id,
						foto => $small,
						href => $href,
						tel_href => $tel_href,
						addr => $addr,
						phone => $static[0],
						url => $url
					};
				} 
			}
		}
	}
	return $data
}

sub do_small_name {
	
	my $class 			= shift;
	my %params 			= !(@_ % 2) ? @_ : (); 
	my $foto = $params{ 'foto' };
	my @foto = split /\// => $foto;
	my $fname = pop @foto;
	push @foto => "small/$fname";
	return "" . join '/' => @foto
	
}

sub json {
	
	my $class 			= shift;
	my %params 			= !(@_ % 2) ? @_ : (); 
	my $data 			= $class->get_branch_data( %params ); 
	my $mobile 			= $ENV{ 'HTTP_MOBILE' };
	my $width			= int $params{ 'width' } || 850;
	my $height			= int $params{ 'height' } || 650;
	my $js_data 		= JSON::to_json( $data->{'js_data'} || '{}' );
	my @out;
	
	push @out => qq[<script type="text/javascript">var coords = $js_data;</script>];
	push @out => qq[
	<script src="https://api-maps.yandex.ru/2.0-stable/?load=package.full&lang=ru-RU" type="text/javascript"></script>
	<script type="text/javascript" src="/js/map-branch.js?22.03.2017"></script>
	<div class="ymap" id="YMapsID" style="width: ${width}px; height: ${height}px; overflow:hidden;"></div>];
	
	return qq[@out]
}

sub menu {
	
	my $class 			= shift;
	my %params 			= !(@_ % 2) ? @_ : ();
	my $data 			= $class->get_branch_data( %params );
	my $mobile 			= $ENV{ 'HTTP_MOBILE' };
	my $mobile_css		= $mobile ? 'mobile' : undef;
	my $width			= 600;
	my $height			= 640;
	my $js_data 		= JSON::to_json( $data->{ 'js_data' } || '{}' );
	my $nav 			= JSON::to_json( $data->{ 'nav' } || '{}' );
	my $order 			= JSON::to_json( $data->{ 'order' } || '[]' ); 
	my @out;
	#my $version		= int rand time; # dev
	my $version			= '2.0'; # stable

	my $OFFERS = sitemodules::Objects::Offers->new();

	my $regionID = $OFFERS->{ 'regionID' };

	my $sth = $sitemodules::DBfunctions::dbh->prepare( qq[
		SELECT
			p.region_id reg, b.branch_id id
		FROM
			branch_tbl b, page_tbl p
		WHERE
			b.page_id = p.page_id
			AND p.region_id = $regionID
	] );

	my $branch;

	while (my $r = $sth->fetchrow_hashref || {}) {
		$branch = $r->{ 'id' } || '';
	}

	notice $branch;

	push @out => qq[
		<script type="text/javascript">
			var branch = '$branch';
	        var coords = $js_data;
	        var coords_order = $order;
	        var coords_nav = $nav;
	    </script>
	];

	push @out => qq[
		<script src="https://api-maps.yandex.ru/2.0-stable/?load=package.full&lang=ru-RU" type="text/javascript"></script>
		<script type="text/javascript" src="/js/map-branch-menu.js?$version"></script>
		<link href="/css/3.0/contact-map.css?$version" type="text/css" rel="stylesheet" />

		<div class="tab $mobile_css" id="contacts">
			<div class="row">
				<div class="cell"><div class="left-menu"></div></div>
				<div class="cell map"><div class="ymap" id="YMapsID" style="width: ${width}px; height: ${height}px; overflow:hidden;"></div></div>
			</div>
		</div>
	];

	return qq[@out];
}

sub data {
	my $class 			= shift;
	my %params 			= !(@_ % 2) ? @_ : ();
	my $data 			= $class->get_branch_data( %params );
	my $mobile 			= $ENV{ 'HTTP_MOBILE' };
	my $container 		= get_setting( "goods" , "branch_templ_face" );
	my $width			= int $params{ 'width' } || 850;
	my $height			= int $params{ 'height' } || 650;
	my $js_data 		= JSON::to_json( $data->{'js_data'} || '{}' );
	my $version			= '3.4';
	my @out;
	
	foreach my $id ( keys %{ $data->{ 'js_data' } || {} } ){
		my $t = qq[<div class="branch-item row"><div class="cell">$data->{ 'js_data' }{ $id }{ 'href' }&nbsp;&nbsp;&nbsp;$data->{ 'js_data' }{ $id }{ 'tel_href' }</div></div>];
		$container =~ s!\{$id\}!$t!ge;
	}
	
	push @out => qq[<script type="text/javascript">var coords = $js_data;</script>];
	push @out => $container;
	push @out => qq[
	<script src="https://api-maps.yandex.ru/2.0-stable/?load=package.full&lang=ru-RU" type="text/javascript"></script>
	<script type="text/javascript" src="/js/map-branch.js?22.03.2017"></script>
	<link href="/css/3.0/contact-map.css?$version" type="text/css" rel="stylesheet" />
	<div class="ymap" id="YMapsID" style="width: ${width}px; height: ${height}px; overflow:hidden;">&nbsp;</div>];
	
	return qq[@out]
}

1;

=head1 AUTHOR

Viktor Bochkarev && Stroykomplekt

=head1 BUGS

it will ...

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2015, Viktor Bochkarev && Stroykomplekt

=cut

