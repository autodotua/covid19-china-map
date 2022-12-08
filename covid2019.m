function covid2019
    start=[2020,1,20];
    stop=[2022,12,08];

    shp=shaperead("maps/分省.shp");
    dataTable=readtable("DXYArea.csv");
    countries=string(dataTable.countryName);
    provinces=string(dataTable.provinceName);
    confirmedCounts=dataTable.province_confirmedCount;
    dates=floor(datenum(dataTable.updateTime));
    uniqueProvince=unique(provinces(countries=="中国"));
    uniqueProvince=uniqueProvince(uniqueProvince~="中国");
    start=datenum(start);
    stop=datenum(stop);

    confirmeds=zeros(stop-start+1,length(uniqueProvince));
    news=zeros(stop-start+1,length(uniqueProvince));

    for date=start:stop
        disp("正在处理"+string(datetime(date,ConvertFrom="datenum")));
        for i=1:length(uniqueProvince)
            index=find(provinces==uniqueProvince(i) & dates==date,1);
            if isempty(index)
                if date~=start
                    confirmeds(date-start+1,i)=confirmeds(date-start,i);
                end
            else
                confirmeds(date-start+1,i)=confirmedCounts(index);
                if  date~=start
                    news(date-start+1,i)=confirmedCounts(index)-confirmeds(date-start,i);
                end
            end
        end
        if date~=start
            draw(shp,datetime(date,ConvertFrom="datenum"),news(date-start+1,:),uniqueProvince);
        end
    end
end


function draw(shp,date,data,provinces)
    clf
    hold on
    names=strings(length(shp),1);
    counts=zeros(length(shp),1);
    types={'0' [0,0] [255,255,255]
        '1-10' [1,10]  [255, 243, 224]
        '11-50' [11,50] [255, 183, 77]
        '51-400' [51,400] [251, 140, 0]
        '401-2000' [401,2000] [244, 67, 54]
        '2001-10000' [2001,10000] [183, 28, 28]
        '>10000' [10000,10000000] [133, 18, 18]
        };
    for type=types'
        fill(nan,nan,type{3}/256);
    end
    for i=1:length(shp)
        from=1;
        to=2;
        x=shp(i).X;
        y=shp(i).Y;
        name=string(shp(i).x0xD00xD00xD50xFE0xC70xF80xBB0xAE_c);
        names(i)=name;
        index=find(standardizeName(provinces)==standardizeName(name));
        if isempty(index)
            error("找不到");
        end
        value=data(index);
        counts(i)=value;
        for type=types'
            range=type{2};
            if value>=range(1) && value<=range(2)
                color=type{3};
                break;
            end
        end
        color=color/256;
        while to<=length(x)
            if isnan(x(to))
                fill(x(from:to-1),y(from:to-1),color);
                from=to+1;
                to=to+2;
            else
                to=to+1;
            end
        end
    end

    nhshp=shaperead("maps/南海.shp");

    for i=1:length(nhshp)
        x=nhshp(i).X;
        y=nhshp(i).Y;
        plot(x,y,'-k');
    end

    xlim([70,155]);
    ylim([2,55]);
    set(gcf,'position',[0,0,800,550])
    axis off
    text(140,50,string(date),Color=[0.5 0.5 0.5],FontSize=18, FontName="微软雅黑");
    text(140,45,string(sum(data)),Color=[0 0 0],FontSize=30, FontName="微软雅黑",FontWeight="bold");
    set(gca, 'FontName', '微软雅黑')
    l=legend(types(:,1),Location='southwest',Box='off');
    l.Title.String="图例";
    l.Title.FontSize=14;
    l.FontSize=12;

    [values,indexs]= maxk(data,12);
    indexs=indexs(values>0);
    maxNames=provinces(indexs);
    maxValues=data(indexs);
    text(130,30,fullName(maxNames), FontName="微软雅黑",Color=[0.2,0.2,0.2],VerticalAlignment="top");
    text(145,30,string(maxValues), FontName="微软雅黑",Color=[0.2 0.2 0.2],VerticalAlignment="top");
    print("outputs/"+string(date,'yyyyMMdd')+".png","-dpng","-r200")
end

function r=standardizeName(name)
    name=replace(name,'省','');
    name=replace(name,'市','');
    name=replace(name,'自治区','');
    name=replace(name,'特别行政区','');
    r=name;
end


function r=fullName(name)

    name=replace(name,'台湾','台湾省');
    name=replace(name,'香港','香港特别行政区');
    name=replace(name,'澳门','澳门特别行政区');
    r=name;
end