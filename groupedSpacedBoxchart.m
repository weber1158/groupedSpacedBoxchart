function axHandle = groupedSpacedBoxchart(dataTable,x,y,groups,varargin)
%Boxcharts with space between groups
%
%Syntax
% groupedSpacedBoxchart(dataTable,x,y,groups)
% groupedSpacedBoxchart(...,varargin)
% axHandle = groupedSpacedBoxchart(...)
%
%Inputs
% dataTable - Table containing your original data
% x - Name of XData variable (ex. 'Month')
% y - Name of YData variable (ex. 'Temperature')
% groups - Name of the variable you wish to group the data by (ex. 'Year')
% varargin - (Optional) name/value pairs compatible with the boxchart() function
%
%Outputs
% axHandle - Chart axes handle
%
%Examples
% load temperature_data
% plt = groupedSpacedBoxchart(data,'Month','TemperatureF','Year');
%
% % With optional inputs
% plt2 = groupedSpacedBoxchart(data,'Month','TemperatureF','Year',...
%        'BoxWidth',0.5,'MarkerStyle','x','notch','on');
% ylim([20 100]), ylabel('Temperature (\circF)')
% legend(categorical(unique(data.Year)))
%
%Inspired by Sudhee's question on MATLAB Answers:
% https://www.mathworks.com/matlabcentral/answers/2120996
%
%See also
% boxchart
%

% Function written by Austin M. Weber 2024

if nargin < 4
    error('Not enough input arguments. The syntax is: groupedSpacedBoxchart(dataTable,x,y,groups,varargin)')
end

% Validate that 'x', 'y', and 'groups' are valid variables in the table
variable_names = dataTable.Properties.VariableNames;
    if ~ismember(x, variable_names)
        error(['''' x '''' ' is not a variable in the table. Check spelling. Variable names are case sensitive.'])
    elseif ~ismember(y, variable_names)
        error(['''' y '''' ' is not a variable in the table. Check spelling. Variable names are case sensitive.'])
    elseif ~ismember(groups, variable_names)
        error(['''' groups '''' ' is not a variable in the table. Check spelling. Variable names are case sensitive.'])
    end

% Ensure that 'x' and 'groups' are categoricals
if ~iscategorical(dataTable.(x))
    dataTable.(x) = categorical(dataTable.(x));
end
if ~iscategorical(dataTable.(groups))
    dataTable.(groups) = categorical(dataTable.(groups));
end

% Get the original number of categories
original_cats = categories(dataTable.(x));
num_cats = numel(original_cats);

% Create a vector of "empty" categories, one to go in-between each of the
% original categories
    emptyvals = num2str((1:num_cats-1)');
    emptynames = repmat('empty',size(emptyvals));
    new_cats = cellstr([emptynames emptyvals]);

% Adjust the category order so that the "empty" categories fit in-between
% the original categories.
new_category_order = cell(num_cats*2-1,1);
new_category_order(1:2:end) = original_cats;
new_category_order(2:2:end-1) = new_cats;

dataTable.(x) = categorical(dataTable.(x),new_category_order);

% Create boxchart figure
if nargin == 4
    % No optional name/value pairs specified; Set BoxWidth=1 by default.
    axHandle=boxchart(dataTable.(x),dataTable.(y),'GroupByColor',dataTable.(groups),'BoxWidth',1);
elseif nargin > 4
    % User specified optional name/value paris. Still sets BoxWidth=1 by
    % default, but if user specifies a different BoxWidth then the user's
    % choice will overwrite the default.
    axHandle=boxchart(dataTable.(x),dataTable.(y),'GroupByColor',dataTable.(groups),'BoxWidth',1,varargin{:});
end

% Set the "empty" categories to invisible characters so that they do not
% show up as x-axis labels. This does not work if the user specifies the
% Orientation='horizontal' name/value pair. Need to patch in a future
% update.
xt = xticks;
xt(2:2:end-1) = categorical(" "); % Invisible character (ATL+255), not a space!
xticklabels(xt)
set(gca,'TickDir','none') % Removes extra x-tick marks at the expense of also removing the y-tick marks

end % Terminate function body