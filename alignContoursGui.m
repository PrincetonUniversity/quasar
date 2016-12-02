function varargout = alignContoursGui(varargin)
% ALIGNCONTOURSGUI MATLAB code for alignContoursGui.fig
%      ALIGNCONTOURSGUI, by itself, creates a new ALIGNCONTOURSGUI or raises the existing
%      singleton*.
%
%      H = ALIGNCONTOURSGUI returns the handle to a new ALIGNCONTOURSGUI or the handle to
%      the existing singleton*.
%
%      ALIGNCONTOURSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNCONTOURSGUI.M with the given input arguments.
%
%      ALIGNCONTOURSGUI('Property','Value',...) creates a new ALIGNCONTOURSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before alignContoursGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to alignContoursGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help alignContoursGui

% Last Modified by GUIDE v2.5 05-May-2016 18:00:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @alignContoursGui_OpeningFcn, ...
    'gui_OutputFcn',  @alignContoursGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before alignContoursGui is made visible.
function alignContoursGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to alignContoursGui (see VARARGIN)

% Choose default command line output for alignContoursGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(handles.figure1,'shiftSize',0.2);


% UIWAIT makes alignContoursGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = alignContoursGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the list of files and which file is selected
fileIdx = get(handles.lbFilelist,'Value');
fileList = get(handles.lbFilelist,'String');

spatialOffsets.green_X = str2double(get(handles.edit3,'String'));
spatialOffsets.green_Y = str2double(get(handles.edit4,'String'));
spatialOffsets.red_X = str2double(get(handles.edit1,'String'));
spatialOffsets.red_Y = str2double(get(handles.edit2,'String'));
save(fileList{fileIdx},'spatialOffsets','-append');





% --- Executes on button press in tbChannel.
function tbChannel_Callback(hObject, eventdata, handles)
% hObject    handle to tbChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(handles.tbChannel,'Value')
    case 0
        set(handles.tbChannel,'ForegroundColor','k');
        set(handles.tbChannel,'CData',repmat(permute([1,0,0],[3,1,2]),[25,125,1]));
        
    case 1
        set(handles.tbChannel,'ForegroundColor','k');
        set(handles.tbChannel,'CData',repmat(permute([0,1,0],[3,1,2]),[25,125,1]));
        
end

displayFluorImage(handles);

% --- Executes on selection change in lbFilelist.
function lbFilelist_Callback(hObject, eventdata, handles)
% hObject    handle to lbFilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbFilelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbFilelist
cla(handles.axes1);

% get the list of files and which file is selected
fileIdx = get(handles.lbFilelist,'Value');
fileList = get(handles.lbFilelist,'String');

try % use the previously saved offsets if they exist
loadedOffsets = load(fileList{fileIdx},'spatialOffsets');

set(handles.edit1,'String',num2str(loadedOffsets.spatialOffsets.red_X));
set(handles.edit2,'String',num2str(loadedOffsets.spatialOffsets.red_Y));
set(handles.edit3,'String',num2str(loadedOffsets.spatialOffsets.green_X));
set(handles.edit4,'String',num2str(loadedOffsets.spatialOffsets.green_Y));

catch ME
    
end

displayFluorImage(handles);

% --- Executes during object creation, after setting all properties.
function lbFilelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbFilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentIndex = get(handles.lbFilelist,'Value');
if currentIndex<= 1;
else
    set(handles.lbFilelist,'Value',currentIndex-1);
end
displayFluorImage(handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentIndex = get(handles.lbFilelist,'Value');
fileList = get(handles.lbFilelist,'String');
if currentIndex>= length(fileList);
else
    set(handles.lbFilelist,'Value',currentIndex+1);
end
displayFluorImage(handles);


% --- Executes on button press in pbSelectFiles.
function pbSelectFiles_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fileList = uipickfiles('filterspec','*contours_pill_mesh.mat');
set(handles.lbFilelist,'String',fileList);
cla(handles.axes1);
displayFluorImage(handles);

function checkForChanges(handles);
% before moving on to the next file or closing the GUI, check to make sure
% changes have been saved


function displayFluorImage(handles);
% get the list of files and which file is selected
fileIdx = get(handles.lbFilelist,'Value');
fileList = get(handles.lbFilelist,'String');

% populate the file names displayed to the user
[parentName,fileName] = fileparts(fileList{fileIdx});
set(handles.text6,'String',parentName);
set(handles.text7, 'String',fileName);

% determine the name of the fluorescence files by first searching for
% c=someNumber in the pill_mesh.
% The naming convention is something like this
% 'Cb_HADA4X_NADA2X_20Min_003.nd2 - s=1 - c=2 - z=0 - t=0_13-Apr-2016_CONTOURS_pill_MESH.mat'
% find where the color channel name starts and ends
[cChannelStringStart,cChannelStringEnd] = regexp(fileName,'c=[0-9]+ ');

% find where the time channel name ends, after this morphometrics appends
% the date and contours, pill-mesh, etc
[~, timeEnd] = regexp(fileName,'t=[0-9]+_');
timeEnd = timeEnd-1;
% the name of the tif that the cntours were derived from
contourTiffName = [fileName(1:timeEnd),'.tif'];
% the color channel name that should be replaced when looking at red and/or
% green
cChannelName = fileName(cChannelStringStart:cChannelStringEnd-1);
redChannelTifName = strrep(fullfile(parentName,contourTiffName),...
    cChannelName, get(handles.edit5,'String'));
greenChannelTifName = strrep(fullfile(parentName,contourTiffName),...
    cChannelName, get(handles.edit6,'String'));


switch get(handles.tbChannel,'Value')
    case 1 % green
        tiffImage = double(imread(greenChannelTifName));
        if get(handles.checkbox2,'value')
            tiffImage = tiffImage-quantile(tiffImage(:),0.005);
            tiffImage = tiffImage./quantile(tiffImage(:),0.999);
        else
            tiffImage = tiffImage-min(tiffImage(:));
            tiffImage = tiffImage./max(tiffImage(:));
        end
        
        
        set(handles.axes1,'Xcolor','g','Ycolor','g','xtick',[],...
            'ytick',[],'linewidth',3);
        axis(handles.axes1,'on');
        
        
    case 0 % red
        tiffImage = double(imread(redChannelTifName));
        
        if get(handles.checkbox2,'value')
            tiffImage = tiffImage-quantile(tiffImage(:),0.005);
            tiffImage = tiffImage./quantile(tiffImage(:),0.999);
        else
            tiffImage = tiffImage-min(tiffImage(:));
            tiffImage = tiffImage./max(tiffImage(:));
        end
        
        set(handles.axes1,'Xcolor','r','Ycolor','r','xtick',[],...
            'ytick',[],'linewidth',3);
        axis(handles.axes1,'on');
        
        
end
try
    if isempty(getappdata(handles.figure1,'imshowHand'))
        assert(false);
    end
    
    set(getappdata(handles.figure1,'imshowHand'),'Cdata',tiffImage);
catch ME2
    cla(handles.axes1);
    imshowHand = imshow(tiffImage,[0,1],'parent',handles.axes1);
    setappdata(handles.figure1,'imshowHand',imshowHand);
    hold on;
end

updateContourPositions(handles);

function updateContourPositions(handles);

% get the list of files and which file is selected
fileIdx = get(handles.lbFilelist,'Value');
fileList = get(handles.lbFilelist,'String');

if isappdata(handles.figure1,'currentlyLoadedContoursFileName');
    currentlyLoadedContoursFileName = getappdata(handles.figure1,'currentlyLoadedContoursFileName');
    
    isReloadContours = not(strcmp(currentlyLoadedContoursFileName,fileList{fileIdx}));
    
else
    currentlyLoadedContoursFileName = fileList{fileIdx};
    isReloadContours = true;
end

if isReloadContours
    loadedContours = load(fileList{fileIdx});
    setappdata(handles.figure1, 'loadedContours',loadedContours);
    setappdata(handles.figure1, 'currentlyLoadedContoursFileName',currentlyLoadedContoursFileName);
else
    loadedContours = getappdata(handles.figure1,'loadedContours');
    
end



switch get(handles.tbChannel,'Value')
    case 1 % green
        offsetX = str2double(get(handles.edit3,'string'));
        offsetY = str2double(get(handles.edit4,'string'));
        
        colorString = 'g';
        
    case 0
        offsetX = str2double(get(handles.edit1,'string'));
        offsetY = str2double(get(handles.edit2,'string'));
        
        colorString = 'r';
        
        
        
end
hold(handles.axes1,'on');

try 
    
if isappdata(handles.figure1,'contourHandles');
    contourHandles = getappdata(handles.figure1,'contourHandles');
    
    if numel( loadedContours.frame.object) == length(contourHandles);
        for iCell = 1:length(loadedContours.frame.object)
            set(contourHandles(iCell),'Xdata',loadedContours.frame.object(iCell).Xcont+offsetX,...
                'Ydata',loadedContours.frame.object(iCell).Ycont+offsetY,...
                'Color',colorString);
        end
    else
        assert(false);
    end
    
else

            assert(false);

end

catch ME
    % something went wrong, remove all the current objects and start over
    clear contourHandles;
    for iCell = 1:length(loadedContours.frame.object)
        hold on;
        contourHandles(iCell) = plot(handles.axes1,...
            loadedContours.frame.object(iCell).Xcont+offsetX,...
            loadedContours.frame.object(iCell).Ycont+offsetY,...
            colorString);
    end
end
setappdata(handles.figure1,'contourHandles',contourHandles);

hold(handles.axes1,'off');


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

updateContourPositions(handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

updateContourPositions(handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
updateContourPositions(handles);


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

updateContourPositions(handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit1,'String',num2str(str2double(get(handles.edit1,'String'))-shiftSize));
updateContourPositions(handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit2,'String',num2str(str2double(get(handles.edit2,'String'))-shiftSize));
updateContourPositions(handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit3,'String',num2str(str2double(get(handles.edit3,'String'))-shiftSize));
updateContourPositions(handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit4,'String',num2str(str2double(get(handles.edit4,'String'))-shiftSize));
updateContourPositions(handles);


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit4,'String',num2str(str2double(get(handles.edit4,'String'))+shiftSize));
updateContourPositions(handles);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit3,'String',num2str(str2double(get(handles.edit3,'String'))+shiftSize));
updateContourPositions(handles);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit2,'String',num2str(str2double(get(handles.edit2,'String'))+shiftSize));
updateContourPositions(handles);

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftSize = (getappdata(handles.figure1,'shiftSize'));
set(handles.edit1,'String',num2str(str2double(get(handles.edit1,'String'))+shiftSize));
updateContourPositions(handles);


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
displayFluorImage(handles);
