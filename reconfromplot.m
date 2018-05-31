function varargout = reconfromplot(varargin)
% RECONFROMPLOT MATLAB code for reconfromplot.fig
%      RECONFROMPLOT, by itself, creates a new RECONFROMPLOT or raises the existing
%      singleton*.
%
%      H = RECONFROMPLOT returns the handle to a new RECONFROMPLOT or the handle to
%      the existing singleton*.
%
%      RECONFROMPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECONFROMPLOT.M with the given input arguments.
%
%      RECONFROMPLOT('Property','Value',...) creates a new RECONFROMPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before reconfromplot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to reconfromplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help reconfromplot

% Last Modified by GUIDE v2.5 08-May-2018 16:42:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reconfromplot_OpeningFcn, ...
                   'gui_OutputFcn',  @reconfromplot_OutputFcn, ...
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


% --- Executes just before reconfromplot is made visible.
function reconfromplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to reconfromplot (see VARARGIN)

% Choose default command line output for reconfromplot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

data = load('features-deg50-cur-selected-binary-interpol-100.mat');

global features mappedX names agg_ids;
features = data.data.features;
names = data.data.filenames;
agg_ids = data.data.agg_ids;

% Sampling 50 aggregates per patient

% samples = [];
% for pat = 1:100
%   I = regexpcell(names, sprintf('^PAT%d\\-DYEcur\\-.*', pat));
%   if length(I) < 50
%     fprintf('Patient %d has less than 50 aggregates (%d)\n', pat, length(I));
%     continue;
%   end
%   samples = [samples, randsample(I, 50)];
% end
% 
% features = features(samples, :);
% names = names(samples);
% agg_ids = agg_ids(samples);


% sampling finishes here


Tbl = readtable('patients-all-dataset-input-new.csv', 'ReadVariableNames', true, 'delimiter', ',');

types = {'Sporadic', 'PSEN1 AD', 'PSEN2 AD', 'London AD', 'E3Q fAD', 'Swedish AD', 'Unknown'};

% this cell holds all patient numbers for each mutation type
% i.e. patients_forEach_type{3} would be all patients suffering
% from 'PSEN2 AD'
patients_forEach_type = {};
for i=1:length(types)
  patients_forEach_type{i} = unique(Tbl(strcmp(Tbl.Classification, types{i}), :).PatientNum);
end

keep = [0, 1, 1, 1, 1, 0, 0];

J = [];
for i=1:length(types)
  if keep(i)
    for pat = patients_forEach_type{i}'
      J = [J, regexpcell(names, sprintf('^%d\\-', pat))];
    end
  end
end

features = features(J, :);
names = names(J);
agg_ids = agg_ids(J);



[mappedX, ~] = compute_mapping(abs(features), 'PCA', 676);
% [mappedX, ~] = compute_mapping(abs(features), 'KernelPCA', 2, 'gauss', 0.5);
% W = SimGraph(abs(features'), 10, 1, 1); % features, number of neighbors, Normal or Mutual, sigma
% [C, L,  mappedX] = specclust(W, 5); % W, k clusters 

axes(handles.axes1);
cla;
hold on;
for i = 1:length(types)
  if ~keep(i); continue; end
  I = [];
  for j = patients_forEach_type{i}'
    I = [I, regexpcell(names, sprintf('^%d\\-', j))];
  end
  s = scatter(mappedX(I, 1), mappedX(I, 2), 15, 'filled', 'DisplayName', types{i});
  set(s,'HitTest','off');
end
hold off;
% legend();
% disp(get(handles.axes1, 'Position'));
axis tight;
set(handles.axes1, 'OuterPosition', get(handles.axes1, 'OuterPosition') + [200, 250, 100, 0]);
% set(gcf, 'OuterPosition', [300 200 1500 7600]);
% set(handles.axes1,'Units','normalized','Position',[0.003, 0.5, 1.8, 1.1]);
% set(handles.axes1,'Units','normalized','Position',[0.001, 0.6, 1.8, 1.1]);
% set(handles.axes1,'Position', [0 0 500 300]);

% --- Outputs from this function are returned to the command line.
function varargout = reconfromplot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global features mappedX names agg_ids;

pt = eventdata.IntersectionPoint(1:2);
distssq = sum((repmat(pt, size(features, 1), 1) - mappedX(:, [2,3])) .^ 2, 2);
[~, I] = min(distssq);

axes(handles.axes1);
hold on;
scatter(mappedX(I, 2), mappedX(I, 3), 150); %draw the circle
hold off;

set(handles.text1, 'String', 'Processing...');

% reconstruct
axes(handles.axes2);
cla;
imshow(reconstructFast(50, 512, features(I, :)));
% load image from file
% imshow(sprintf('aggregatesSelect/%s-agg-%d.png', names{I}, agg_ids(I)));

set(handles.text1, 'String', sprintf('Ready\n[%s]', names{I}));
