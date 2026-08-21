clc;
clear all;
close all;

cd '/Users/Macbook/Desktop/All';
list = dir('*.jpg'); 
number_of_files = size(list);
fig=figure(1);

for i = 2: number_of_files(1,1) %
    
    filename = list(i).name; %
    I = imread(filename); %
    
    %%%%%%% RESMİN ORTASINI SEÇME VE DÜZENLEMELER %%%%%%%%%%
    
    [boy, en, rgb] = size(I); % resmin boyutlarını değişkenlere atadım.
    x_baslangic = en * 0.35;    
    y_baslangic = 1;          % sağdan ve soldan %35 kesip ortadaki %30u ve yüksekliğin tamamını aldım.
    genislik = en * 0.30;     
   
    I_crop = imcrop(I, [x_baslangic, y_baslangic, genislik, boy]);
    

    I_gray=im2gray(I_crop);     % kırpılmış resmi gri tonlamalıya çevirdim. 

    if mean(I_gray, 'all') > 210
        fprintf('%s - ŞİŞE YOK)\n', filename);
        durum_mesaji = 'Şişe Yok'; 

        continue;
    end

    h = fspecial('gaussian', [5 5], 0.5); % gauss filtresi 
    I_gauss=imfilter(I_gray,h);

    I_yataykenar = edge(I_gauss, 'sobel', 'horizontal');
    % imshow(I_yataykenar);
    % pause(0.3);

    %%%%%%%%%  KOLA SEVİYESİNi BULMA %%%%%%%%%%
    [c_boy, c_en] = size(I_yataykenar);
    orta_sutun = round(c_en / 2);
    tarama_araligi = (orta_sutun-20):(orta_sutun+20);
    bulunan_seviyeler = []; 
    
    for col = tarama_araligi
        beyaz_pikseller = find(I_yataykenar(60:end, col) == 1); %kapak kısmınına bakmamak için 30.satırdan başlattım.
        if ~isempty(beyaz_pikseller)
            bulunan_seviyeler = [bulunan_seviyeler, beyaz_pikseller(1) + 60]; %
        end
    end
    
    if ~isempty(bulunan_seviyeler)
        sivi_seviyesi_y = round(median(bulunan_seviyeler)); 

        if sivi_seviyesi_y < 111
            fprintf('%s - Fazla Dolum\n', filename);
            durum_mesaji = 'Fazla Dolum';
        elseif sivi_seviyesi_y >= 111 && sivi_seviyesi_y <= 160
            fprintf('%s - Normal Dolum\n', filename);
            durum_mesaji = 'Normal Dolum';
        elseif sivi_seviyesi_y > 160 && sivi_seviyesi_y < 190
            fprintf('%s - Az Dolum\n', filename);
            durum_mesaji = 'Az Dolum';
        else
             fprintf('%s - BOŞ ŞİŞE\n', filename);
            durum_mesaji = 'BOŞ ŞİŞE';
        end
    else
        sivi_seviyesi_y = 0;
        fprintf('%s - Sıvı Çizgisi Yok! (Boş Şişe)\n', filename);
        durum_mesaji = 'BOŞ ŞİŞE';
    end
    
    if ishandle(fig)
        clf(fig);
        imshow(I_crop); 
        hold on;
        if sivi_seviyesi_y > 0
            plot([1, c_en], [sivi_seviyesi_y, sivi_seviyesi_y], 'r-', 'LineWidth', 2);
        end
        title([filename, ' -> ', durum_mesaji]);
        hold off;
        pause(2);
    end


   %%%%%%%% ETİKET KONTROL %%%%%%%%%
 
    I_red = I_crop(:,:,1);
    I_etiketkontrol = I_red > 100;
    
    beyaz_sol = find(I_etiketkontrol(175:250, orta_sutun-20) == 1);
    beyaz_sag = find(I_etiketkontrol(175:250, orta_sutun+20) == 1);
    
    if isempty(beyaz_sol) || isempty(beyaz_sag)
        fprintf('%s - Etiket Eksik\n', filename);
        etiket_mesaji = 'Etiket Eksik';
        
    else
        sol_baslangic_y = beyaz_sol(1);
        sag_baslangic_y = beyaz_sag(1);
        
        %beyaz etiket kontrolü
        etiket_bolgesi_yesil = I_crop(175:250, (orta_sutun-20):(orta_sutun+20), 2);%etiket beyaz ise yeşil kanalının büyük bir değer alması lazım
        ortalama_yesil = mean(etiket_bolgesi_yesil, 'all');
        
        if ortalama_yesil > 180
            
            fprintf('%s - Hatalı Etiket Baskısı (Beyaz)\n', filename);
            etiket_mesaji = 'Hatalı Baskı';
            
        else
            if abs(sol_baslangic_y - sag_baslangic_y) > 4
                fprintf('%s - Etiket Yamuk\n', filename);
                etiket_mesaji = 'Etiket Yamuk';
            else
                fprintf('%s - Etiket Düzgün.\n', filename);
                etiket_mesaji = 'Etiket Düzgün';
            end
        end
    end



    %%%%%%% KAPAK KONTROL %%%%%%%%
    I_green = I_crop(:,:,2); %yine yeşil kanala geçtim kırmızı ayıklamak hatalı çıktı.
    I_kapak_bolgesi = I_green(1:40, (orta_sutun-15):(orta_sutun+15)); 
    
    ortalama_kapak_yesil = mean(I_kapak_bolgesi, 'all');

    if ortalama_kapak_yesil > 175
        fprintf('%s - Kapak Eksik\n', filename);
        kapak_mesaji = 'Kapak Eksik';
    else
        fprintf('%s - Kapak Var\n', filename);
        kapak_mesaji = 'Kapak Var';
    end


    %%%%% DEFORMASYON KONTROLÜ%%%%%
    deforme_mesaji = 'Şişe Sağlam'; % Varsayılan durum
    
    I_green_deforme = I_crop(:,:,2);
    
    tarama_satirlari = 100:5:180;
    
    toplam_asimetri = 0;
    gecerli_satir_sayisi = 0;
    
    for r = tarama_satirlari
        pikseller = find(I_green_deforme(r, :) < 150);
        
        if length(pikseller) >= 2
            sol_kenar = pikseller(1);
            sag_kenar = pikseller(end);
            
            sol_uzaklik = abs(orta_sutun - sol_kenar);
            sag_uzaklik = abs(sag_kenar - orta_sutun);
            
            toplam_asimetri = toplam_asimetri + abs(sol_uzaklik - sag_uzaklik);
            gecerli_satir_sayisi = gecerli_satir_sayisi + 1;
        end
    end

    if gecerli_satir_sayisi > 0
        ortalama_sapma = toplam_asimetri / gecerli_satir_sayisi;
        
        if ortalama_sapma > 7.5
            fprintf('%s - Şişe Deforme\n', filename);
            deforme_mesaji = 'Deforme Şişe';
        else
            fprintf('%s - Şişe Sağlam.\n', filename);
        end
    else
        fprintf('%s - Şişe Sağlam.\n', filename);
    end
end
