%% Takes split ND2s (TIFFs), deletes the even numbered-numbered ones, merges TIFFs 3 & 5.


folderName = uigetdir();
%%
fileList = dir([folderName,filesep,'*c=0*.tif']);
%
%disp([fileList.name]);
%%
for iFile = 1:length(fileList);
    %    % delete
    %    c=1 is phase
    %    %
    %    c=3 is old, second image plane
    %    %
    %    c=5 is new, first image plane
    %
    initialND2stemIdx = strfind(fileList(iFile).name,'.nd2');
    initialND2Name = fileList(iFile).name;
    initialND2Name(initialND2stemIdx+4:end) =[];
    disp(initialND2Name);
    
%     movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=1')],...
%         [folderName,filesep,initialND2Name,' c=1.tif']);
    
    mkdir(folderName,'uselessEvenNumbers');
    mkdir(folderName,'ND2');
    
        
%     tempImage = imread([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=3')]);
%     tempImage = cat(3,tempImage,imread([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=3')]));
%     tiffwrite([folderName,filesep,initialND2Name,'.tif'],tempImage);
% 

    if exist([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=0')]);
        
        movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=0')],...
            [folderName,filesep,'uselessEvenNumbers',filesep]);
    end
    if exist([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=2')]);
        
        movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=2')],...
            [folderName,filesep,'uselessEvenNumbers',filesep]);
    end
    if exist([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=4')]);
        
        movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=4')],...
            [folderName,filesep,'uselessEvenNumbers',filesep]);
    end
        if exist([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=1')]);
        
        movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=1')],...
            [folderName,filesep,strrep(fileList(iFile).name,'c=0','c=0')]);
        end
        if exist([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=3')]);
        
        movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=3')],...
            [folderName,filesep,strrep(fileList(iFile).name,'c=0','c=1')]);
        end
        if exist([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=5')]);
        
        movefile([folderName,filesep,strrep(fileList(iFile).name,'c=0','c=5')],...
            [folderName,filesep,'uselessEvenNumbers',filesep]);
        end
     if exist([folderName,filesep,initialND2Name])
         movefile([folderName,filesep,initialND2Name],...
             [folderName,filesep,'ND2',filesep]);
     end
end

