classdef NewModelApp < handle
    % NewModelApp - 一键新建 Simulink 模型工具
    %   GUI 界面支持：
    %   - 输入模型名称
    %   - 勾选离散模型，设置时间步长
    %   - 选择 TLC 文件（默认 ert.tlc）
    %   - 勾选仅生成代码
    %   - 关联数据字典（勾选后选择 .sldd 文件）
    %   - 从 Excel 导入端口（勾选后选择 Excel 文件）
    %   - 不勾选导入端口时创建空模型

    properties (Access = public)
        % 主窗口
        UIFigure           matlab.ui.Figure

        % 模型名称
        NameLabel          matlab.ui.control.Label
        NameEditField      matlab.ui.control.EditField

        % 离散模型
        DiscreteCheckBox   matlab.ui.control.CheckBox
        SampleTimeLabel    matlab.ui.control.Label
        SampleTimeEditField matlab.ui.control.EditField

        % TLC 文件
        TLCLabel           matlab.ui.control.Label
        TLCEditField       matlab.ui.control.EditField
        TLCBrowseButton    matlab.ui.control.Button

        % 仅生成代码
        GenCodeOnlyCheckBox matlab.ui.control.CheckBox

        % 数据字典
        DictCheckBox       matlab.ui.control.CheckBox
        DictPathLabel      matlab.ui.control.Label
        DictEditField      matlab.ui.control.EditField
        DictBrowseButton   matlab.ui.control.Button

        % Excel 导入
        ExcelCheckBox      matlab.ui.control.CheckBox
        ExcelPathLabel     matlab.ui.control.Label
        ExcelEditField     matlab.ui.control.EditField
        ExcelBrowseButton  matlab.ui.control.Button
        ExcelCodeMapCheckBox matlab.ui.control.CheckBox
        OpenModelCheckBox  matlab.ui.control.CheckBox

        % 按钮
        CreateButton       matlab.ui.control.Button

        % 状态栏
        StatusLabel        matlab.ui.control.Label
    end

    % =====================================================================
    % 构造 / 析构
    % =====================================================================
    methods
        function app = NewModelApp()
            % 构造 app，创建 UI 组件
            app.createComponents();
        end

        function delete(app)
            % 析构时关闭窗口
            if isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end

    % =====================================================================
    % 界面创建
    % =====================================================================
    methods (Access = private)
        function createComponents(app)
            % 创建主窗口
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100, 100, 540, 500];
            app.UIFigure.Name = '新建 Simulink 模型';
            app.UIFigure.Resize = 'off';
            app.UIFigure.Scrollable = 'off';

            % ---- 标题 ----
            titleLabel = uilabel(app.UIFigure);
            titleLabel.Position = [10, 455, 520, 30];
            titleLabel.Text = '新建 Simulink 模型';
            titleLabel.FontSize = 20;
            titleLabel.FontWeight = 'bold';
            titleLabel.HorizontalAlignment = 'center';

            % ---- 分隔线 ----
            sep = uilabel(app.UIFigure);
            sep.Position = [10, 445, 520, 2];
            sep.BackgroundColor = [0.7 0.7 0.7];
            sep.Text = '';

            % ---- 模型名称 ----
            app.NameLabel = uilabel(app.UIFigure);
            app.NameLabel.Position = [20, 410, 80, 22];
            app.NameLabel.Text = '模型名称:';
            app.NameLabel.FontSize = 12;

            app.NameEditField = uieditfield(app.UIFigure, 'text');
            app.NameEditField.Position = [110, 410, 410, 24];
            app.NameEditField.Value = 'myModel';
            app.NameEditField.Tooltip = '输入有效的 MATLAB 标识符（字母开头，无空格）';

            % ---- 离散模型 ----
            app.DiscreteCheckBox = uicheckbox(app.UIFigure);
            app.DiscreteCheckBox.Position = [20, 378, 200, 22];
            app.DiscreteCheckBox.Text = '离散模型';
            app.DiscreteCheckBox.FontSize = 12;
            app.DiscreteCheckBox.ValueChangedFcn = @(s, ~) app.onDiscreteToggled(s.Value);

            % ---- 时间步长 ----
            app.SampleTimeLabel = uilabel(app.UIFigure);
            app.SampleTimeLabel.Position = [40, 348, 80, 22];
            app.SampleTimeLabel.Text = '时间步长:';
            app.SampleTimeLabel.Enable = 'off';

            app.SampleTimeEditField = uieditfield(app.UIFigure, 'text');
            app.SampleTimeEditField.Position = [130, 348, 100, 22];
            app.SampleTimeEditField.Value = '0.01';
            app.SampleTimeEditField.Enable = 'off';
            app.SampleTimeEditField.Tooltip = '固定步长大小（秒）';

            % ---- TLC 文件 ----
            app.TLCLabel = uilabel(app.UIFigure);
            app.TLCLabel.Position = [20, 315, 80, 22];
            app.TLCLabel.Text = 'TLC 文件:';
            app.TLCLabel.FontSize = 12;

            app.TLCEditField = uieditfield(app.UIFigure, 'text');
            app.TLCEditField.Position = [110, 315, 330, 22];
            app.TLCEditField.Value = 'ert.tlc';
            app.TLCEditField.Tooltip = '代码生成系统目标文件';

            app.TLCBrowseButton = uibutton(app.UIFigure, 'push');
            app.TLCBrowseButton.Position = [450, 315, 70, 22];
            app.TLCBrowseButton.Text = '浏览...';
            app.TLCBrowseButton.ButtonPushedFcn = @(~, ~) app.browseTLC();

            % ---- 仅生成代码 ----
            app.GenCodeOnlyCheckBox = uicheckbox(app.UIFigure);
            app.GenCodeOnlyCheckBox.Position = [20, 283, 200, 22];
            app.GenCodeOnlyCheckBox.Text = '仅生成代码';
            app.GenCodeOnlyCheckBox.FontSize = 12;
            app.GenCodeOnlyCheckBox.Tooltip = '仅生成代码，不编译';

            % ---- 数据字典 ----
            app.DictCheckBox = uicheckbox(app.UIFigure);
            app.DictCheckBox.Position = [20, 248, 250, 22];
            app.DictCheckBox.Text = '关联数据字典';
            app.DictCheckBox.FontSize = 12;
            app.DictCheckBox.ValueChangedFcn = @(s, ~) app.onDictToggled(s.Value);

            app.DictPathLabel = uilabel(app.UIFigure);
            app.DictPathLabel.Position = [40, 218, 80, 22];
            app.DictPathLabel.Text = '字典路径:';
            app.DictPathLabel.Enable = 'off';

            app.DictEditField = uieditfield(app.UIFigure, 'text');
            app.DictEditField.Position = [130, 218, 310, 22];
            app.DictEditField.Enable = 'off';
            app.DictEditField.Tooltip = '选择 .sldd 数据字典文件';

            app.DictBrowseButton = uibutton(app.UIFigure, 'push');
            app.DictBrowseButton.Position = [450, 218, 70, 22];
            app.DictBrowseButton.Text = '浏览...';
            app.DictBrowseButton.Enable = 'off';
            app.DictBrowseButton.ButtonPushedFcn = @(~, ~) app.browseDict();

            % ---- Excel 导入 ----
            app.ExcelCheckBox = uicheckbox(app.UIFigure);
            app.ExcelCheckBox.Position = [20, 183, 250, 22];
            app.ExcelCheckBox.Text = '从 Excel 导入端口';
            app.ExcelCheckBox.FontSize = 12;
            app.ExcelCheckBox.ValueChangedFcn = @(s, ~) app.onExcelToggled(s.Value);

            app.ExcelPathLabel = uilabel(app.UIFigure);
            app.ExcelPathLabel.Position = [40, 153, 80, 22];
            app.ExcelPathLabel.Text = 'Excel 路径:';
            app.ExcelPathLabel.Enable = 'off';

            app.ExcelEditField = uieditfield(app.UIFigure, 'text');
            app.ExcelEditField.Position = [130, 153, 310, 22];
            app.ExcelEditField.Enable = 'off';
            app.ExcelEditField.Tooltip = 'Excel 文件，需包含 Input/Output 工作表或节标题';

            app.ExcelBrowseButton = uibutton(app.UIFigure, 'push');
            app.ExcelBrowseButton.Position = [450, 153, 70, 22];
            app.ExcelBrowseButton.Text = '浏览...';
            app.ExcelBrowseButton.Enable = 'off';
            app.ExcelBrowseButton.ButtonPushedFcn = @(~, ~) app.browseExcel();

            % ---- Code Mapping ----
            app.ExcelCodeMapCheckBox = uicheckbox(app.UIFigure);
            app.ExcelCodeMapCheckBox.Position = [40, 128, 350, 22];
            app.ExcelCodeMapCheckBox.Text = '使用 Code Mapping（设置 StorageClass / Identifier）';
            app.ExcelCodeMapCheckBox.FontSize = 12;
            app.ExcelCodeMapCheckBox.Enable = 'off';
            app.ExcelCodeMapCheckBox.Tooltip = '勾选后，用 Excel 中的 StorageClass 和 Identifier 列通过 Simulink.CodeMapping API 配置端口';

            % ---- 打开模型 ----
            app.OpenModelCheckBox = uicheckbox(app.UIFigure);
            app.OpenModelCheckBox.Position = [20, 72, 250, 22];
            app.OpenModelCheckBox.Text = '创建后打开模型';
            app.OpenModelCheckBox.FontSize = 12;
            app.OpenModelCheckBox.Value = true;
            app.OpenModelCheckBox.Tooltip = '勾选后创建完模型保持打开状态；不勾选则保存后关闭';

            % ---- 创建按钮 ----
            app.CreateButton = uibutton(app.UIFigure, 'push');
            app.CreateButton.Position = [190, 95, 160, 36];
            app.CreateButton.Text = '创建模型';
            app.CreateButton.FontSize = 14;
            app.CreateButton.FontWeight = 'bold';
            app.CreateButton.BackgroundColor = [0.15, 0.55, 0.15];
            app.CreateButton.FontColor = [1, 1, 1];
            app.CreateButton.ButtonPushedFcn = @(~, ~) app.createModel();

            % ---- 状态栏 ----
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [20, 20, 500, 50];
            app.StatusLabel.Text = '就绪';
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontColor = [0.4, 0.4, 0.4];
            app.StatusLabel.FontSize = 12;
            app.StatusLabel.WordWrap = 'on';

            % ---- 显示窗口 ----
            movegui(app.UIFigure, 'center');
            app.UIFigure.Visible = 'on';
        end
    end

    % =====================================================================
    % 界面交互回调
    % =====================================================================
    methods (Access = private)
        function onDiscreteToggled(app, isChecked)
            % 离散模型勾选切换
            if isChecked
                app.SampleTimeLabel.Enable = 'on';
                app.SampleTimeEditField.Enable = 'on';
            else
                app.SampleTimeLabel.Enable = 'off';
                app.SampleTimeEditField.Enable = 'off';
            end
        end

        function onDictToggled(app, isChecked)
            % 数据字典勾选切换
            if isChecked
                app.DictPathLabel.Enable = 'on';
                app.DictEditField.Enable = 'on';
                app.DictBrowseButton.Enable = 'on';
            else
                app.DictPathLabel.Enable = 'off';
                app.DictEditField.Enable = 'off';
                app.DictBrowseButton.Enable = 'off';
            end
        end

        function onExcelToggled(app, isChecked)
            % Excel 导入勾选切换
            if isChecked
                app.ExcelPathLabel.Enable = 'on';
                app.ExcelEditField.Enable = 'on';
                app.ExcelBrowseButton.Enable = 'on';
                app.ExcelCodeMapCheckBox.Enable = 'on';
            else
                app.ExcelPathLabel.Enable = 'off';
                app.ExcelEditField.Enable = 'off';
                app.ExcelBrowseButton.Enable = 'off';
                app.ExcelCodeMapCheckBox.Enable = 'off';
            end
        end

        function browseTLC(app)
            [file, path] = uigetfile( ...
                {'*.tlc', 'TLC 文件 (*.tlc)'; '*.*', '所有文件 (*.*)'}, ...
                '选择系统目标文件');
            if isequal(file, 0); return; end
            app.TLCEditField.Value = fullfile(path, file);
        end

        function browseDict(app)
            [file, path] = uigetfile( ...
                {'*.sldd', '数据字典文件 (*.sldd)'; '*.*', '所有文件 (*.*)'}, ...
                '选择数据字典');
            if isequal(file, 0); return; end
            app.DictEditField.Value = fullfile(path, file);
            % uigetfile 后把 GUI 窗口拉回前台
            figure(app.UIFigure);
        end

        function browseExcel(app)
            [file, path] = uigetfile( ...
                {'*.xlsx;*.xls', 'Excel 文件 (*.xlsx, *.xls)'; '*.*', '所有文件 (*.*)'}, ...
                '选择 Excel 文件');
            if isequal(file, 0); return; end
            app.ExcelEditField.Value = fullfile(path, file);
            % uigetfile 后把 GUI 窗口拉回前台
            figure(app.UIFigure);
        end
    end

    % =====================================================================
    % 核心：创建模型
    % =====================================================================
    methods (Access = private)
        function createModel(app)
            % 主入口：验证输入 → 创建模型 → 配置 → 导入端口 → 保存

            % ---- 状态栏重置 ----
            app.StatusLabel.FontColor = [0.4, 0.4, 0.4];
            app.StatusLabel.Text = '正在创建模型...';
            drawnow;

            % ---- 验证模型名称 ----
            modelName = strtrim(app.NameEditField.Value);
            if isempty(modelName)
                app.showError('请输入模型名称！');
                return;
            end
            if ~isvarname(modelName)
                app.showError('模型名称不是有效的 MATLAB 标识符！\n（需以字母开头，只能包含字母、数字、下划线）');
                return;
            end

            % ---- 检查是否已存在，让用户选择处理方式 ----
            modelExists = bdIsLoaded(modelName) || (exist(modelName, 'file') == 4);

            if modelExists
                if bdIsLoaded(modelName)
                    msg = sprintf('模型 "%s" 已经在工作区中加载。\n请选择处理方式：', modelName);
                else
                    msg = sprintf('模型文件 "%s.slx" 已存在。\n请选择处理方式：', modelName);
                end

                choice = uiconfirm(app.UIFigure, msg, '模型已存在', ...
                    'Options', {'覆盖', '加数字后缀', '取消'}, ...
                    'DefaultOption', 2, ...
                    'CancelOption', 3, ...
                    'Icon', 'question');

                switch choice
                    case '覆盖'
                        % 关闭（不保存）并删除已有模型文件
                        try
                            if bdIsLoaded(modelName)
                                close_system(modelName, 0);
                            end
                            if exist(modelName, 'file') == 4
                                delete([modelName, '.slx']);
                            end
                        catch ME
                            app.showError(sprintf('无法清理已有模型: %s', ME.message));
                            return;
                        end

                    case '加数字后缀'
                        % 查找下一个可用名称：modelName1, modelName2, ...
                        suffix = 1;
                        while true
                            newName = sprintf('%s%d', modelName, suffix);
                            if ~bdIsLoaded(newName) && exist(newName, 'file') ~= 4
                                modelName = newName;
                                break;
                            end
                            suffix = suffix + 1;
                        end
                        % 将新名称回填到输入框
                        app.NameEditField.Value = modelName;

                    otherwise  % '取消' 或直接关闭对话框
                        app.StatusLabel.FontColor = [0.4, 0.4, 0.4];
                        app.StatusLabel.Text = '已取消';
                        return;
                end
            end

            % ---- 开始创建 ----
            try
                % ===== 1. 创建空模型 =====
                app.StatusLabel.Text = sprintf('正在创建模型 "%s"...', modelName);
                drawnow;

                new_system(modelName);
                open_system(modelName);

                % ===== 2. 求解器配置 =====
                if app.DiscreteCheckBox.Value
                    sampleTime = str2double(app.SampleTimeEditField.Value);
                    if isnan(sampleTime) || sampleTime <= 0
                        close_system(modelName, 0);
                        app.showError('请输入有效的时间步长（正数）！');
                        return;
                    end
                    set_param(modelName, ...
                        'SolverType',        'Fixed-step', ...
                        'Solver',            'FixedStepDiscrete', ...
                        'FixedStep',         num2str(sampleTime));
                else
                    set_param(modelName, ...
                        'SolverType',        'Variable-step', ...
                        'Solver',            'VariableStepAuto');
                end

                % ===== 3. 代码生成 - 系统目标文件（TLC） =====
                tlcFile = strtrim(app.TLCEditField.Value);
                if ~isempty(tlcFile)
                    set_param(modelName, 'SystemTargetFile', tlcFile);
                end

                % ===== 4. 仅生成代码 =====
                if app.GenCodeOnlyCheckBox.Value
                    set_param(modelName, 'GenCodeOnly', 'on');
                else
                    set_param(modelName, 'GenCodeOnly', 'off');
                end

                % ===== 5. 关联数据字典 =====
                if app.DictCheckBox.Value
                    dictFile = strtrim(app.DictEditField.Value);
                    if ~isempty(dictFile)
                        [dictDir, dictName, dictExt] = fileparts(dictFile);
                        if isempty(dictExt)
                            fullDictPath = fullfile(dictDir, [dictName, '.sldd']);
                        else
                            fullDictPath = dictFile;
                        end

                        % 直接用 set_param 关联数据字典（只需文件名，不含路径）
                        if exist(fullDictPath, 'file')
                            [~, dictBase, dictExt] = fileparts(fullDictPath);
                            dictFileName = [dictBase, dictExt];
                            try
                                set_param(modelName, 'DataDictionary', dictFileName);
                                app.StatusLabel.FontColor = [0, 0.5, 0];
                                app.StatusLabel.Text = sprintf('✓ 已关联数据字典: %s', dictFileName);
                            catch ME2
                                app.showWarning(sprintf('无法关联数据字典: %s', ME2.message));
                            end
                        else
                            app.showWarning(sprintf('数据字典文件不存在: %s\n请先创建 .sldd 文件后再试。', fullDictPath));
                        end
                    end
                end

                % ===== 6. 从 Excel 导入端口 =====
                importCount = '';
                inputPorts = {};
                outputPorts = {};
                if app.ExcelCheckBox.Value
                    excelFile = strtrim(app.ExcelEditField.Value);
                    if isempty(excelFile)
                        close_system(modelName, 0);
                        app.showError('请选择 Excel 文件或取消「从 Excel 导入端口」勾选');
                        return;
                    end
                    if ~exist(excelFile, 'file')
                        close_system(modelName, 0);
                        app.showError(sprintf('Excel 文件不存在：\n%s', excelFile));
                        return;
                    end

                    [inputPorts, outputPorts] = app.importPortsFromExcel(modelName, excelFile);
                    nIn = length(inputPorts);
                    nOut = length(outputPorts);
                    importCount = sprintf('（导入 %d 个输入端口，%d 个输出端口）', nIn, nOut);

                    % ===== 6a. 检查端口是否有 Code Mapping 相关列 =====
                    cmApplied = app.ExcelCodeMapCheckBox.Value;
                    if cmApplied
                        hasSC = false;
                        for tmpIdx = 1:length(inputPorts)
                            p = inputPorts{tmpIdx};
                            if ~isempty(p.storageClass) || ~isempty(p.identifier) || ...
                                    ~isempty(p.headerFile) || ~isempty(p.definitionFile)
                                hasSC = true; break;
                            end
                        end
                        if ~hasSC
                            for tmpIdx = 1:length(outputPorts)
                                p = outputPorts{tmpIdx};
                                if ~isempty(p.storageClass) || ~isempty(p.identifier) || ...
                                        ~isempty(p.headerFile) || ~isempty(p.definitionFile)
                                    hasSC = true; break;
                                end
                            end
                        end
                        cmApplied = hasSC;
                    end
                end

                % ===== 7. 保存模型（先保存，后续 Code Mapping 才能生效） =====
                save_system(modelName);

                % ===== 7a. 保存后再执行 Code Mapping =====
                if app.ExcelCodeMapCheckBox.Value && cmApplied
                    try
                        % 重新打开已保存的模型，创建 Code Mapping 对象
                        if ~bdIsLoaded(modelName)
                            load_system(modelName);
                        end
                        cmObj = coder.mapping.utils.create(modelName);
                        % 输入端口
                        for pIdx = 1:length(inputPorts)
                            p = inputPorts{pIdx};
                            nvPairs = {};
                            if ~isempty(p.storageClass)
                                nvPairs = [nvPairs, {'StorageClass', p.storageClass}];
                            else
                                nvPairs = [nvPairs, {'StorageClass', 'Auto'}];
                            end
                            if ~isempty(p.identifier)
                                nvPairs = [nvPairs, {'Identifier', p.identifier}];
                            end
                            if ~isempty(p.headerFile)
                                nvPairs = [nvPairs, {'HeaderFile', p.headerFile}];
                            end
                            if ~isempty(p.definitionFile)
                                nvPairs = [nvPairs, {'DefinitionFile', p.definitionFile}];
                            end
                            setInport(cmObj, p.name, nvPairs{:});
                        end
                        % 输出端口
                        for pIdx = 1:length(outputPorts)
                            p = outputPorts{pIdx};
                            nvPairs = {};
                            if ~isempty(p.storageClass)
                                nvPairs = [nvPairs, {'StorageClass', p.storageClass}];
                            else
                                nvPairs = [nvPairs, {'StorageClass', 'Auto'}];
                            end
                            if ~isempty(p.identifier)
                                nvPairs = [nvPairs, {'Identifier', p.identifier}];
                            end
                            if ~isempty(p.headerFile)
                                nvPairs = [nvPairs, {'HeaderFile', p.headerFile}];
                            end
                            if ~isempty(p.definitionFile)
                                nvPairs = [nvPairs, {'DefinitionFile', p.definitionFile}];
                            end
                            setOutport(cmObj, p.name, nvPairs{:});
                        end
                        % 再次保存以写入 Code Mapping 配置
                        save_system(modelName);
                        importCount = [importCount, ' + Code Mapping'];
                    catch ME_cm2
                        app.showWarning(sprintf('Code Mapping 设置失败: %s\n端口仍已创建。', ME_cm2.message));
                    end
                end

                if app.OpenModelCheckBox.Value
                    % 保持打开
                else
                    close_system(modelName);
                end

                % ---- 成功 ----
                app.StatusLabel.FontColor = [0, 0.5, 0];
                app.StatusLabel.Text = sprintf('✓ 模型 "%s" 创建成功%s', modelName, importCount);

            catch ME
                % 出错时清理
                try
                    if bdIsLoaded(modelName)
                        close_system(modelName, 0);
                    end
                catch
                    % 忽略清理错误
                end
                app.showError(sprintf('创建失败：%s', ME.message));
            end
        end
    end

    % =====================================================================
    % Excel 端口导入
    % =====================================================================
    methods (Access = private)
        function [inputPorts, outputPorts] = importPortsFromExcel(app, modelName, excelFile)
            % 从 Excel 读取输入/输出端口定义并添加到模型中
            %   格式A：两个工作表 "Input" 和 "Output"
            %   格式B：单个工作表，用 "Input" / "Output" 节标题分隔
            %
            % 每列含义（由 PortExtractor 生成）:
            %   列A: 序号（跳过）
            %   列B: 端口名称（必填）
            %   列C: 数据类型（可选）
            %   列D: StorageClass（可选，用于 Code Mapping）
            %   列E: Identifier（可选，用于 Code Mapping）
            %   列F: HeaderFile（可选，用于 Code Mapping）
            %   列G: DefinitionFile（可选，用于 Code Mapping）
            %
            % 返回: inputPorts, outputPorts — 端口 struct 数组（含 name / dataType / storageClass / identifier / headerFile / definitionFile）



            inputPorts = {};
            outputPorts = {};

            % 获取工作表信息
            [~, sheets] = xlsfinfo(excelFile);

            inputRaw = [];
            outputRaw = [];

            % 匹配多种可能的 sheet 名称
            inSheets  = {'Inputs', 'Input', '输入'};
            outSheets = {'Outputs', 'Output', '输出'};

            inIdx = find(ismember(inSheets, sheets), 1);
            if ~isempty(inIdx)
                [~, ~, inputRaw] = xlsread(excelFile, inSheets{inIdx});
            end

            outIdx = find(ismember(outSheets, sheets), 1);
            if ~isempty(outIdx)
                [~, ~, outputRaw] = xlsread(excelFile, outSheets{outIdx});
            end

            % 如果都没找到，尝试单工作表单文件
            if isempty(inputRaw) && isempty(outputRaw)
                [~, ~, raw] = xlsread(excelFile);
                if ~isempty(raw)
                    [inputRaw, outputRaw] = app.splitBySection(raw);
                end
            end

            % ---- 创建输入端口（左侧纵向排列） ----
            inputPorts = app.parsePortTable(inputRaw);
            inY = 80;
            for i = 1:length(inputPorts)
                p = inputPorts{i};
                blockPath = sprintf('%s/%s', modelName, p.name);
                add_block('simulink/Sources/In1', blockPath);
                set_param(blockPath, 'Position', [60, inY, 90, inY + 14]);
                if ~isempty(p.dataType) && ~strcmp(p.dataType, 'Inherit: auto')
                    set_param(blockPath, 'OutDataTypeStr', p.dataType);
                end
                inY = inY + 50;
            end

            % ---- 创建输出端口（右侧纵向排列） ----
            outputPorts = app.parsePortTable(outputRaw);
            outY = 80;
            for i = 1:length(outputPorts)
                p = outputPorts{i};
                blockPath = sprintf('%s/%s', modelName, p.name);
                add_block('simulink/Sinks/Out1', blockPath);
                set_param(blockPath, 'Position', [500, outY, 530, outY + 14]);
                if ~isempty(p.dataType) && ~strcmp(p.dataType, 'Inherit: auto')
                    set_param(blockPath, 'OutDataTypeStr', p.dataType);
                end
                outY = outY + 50;
            end
        end

        function [inputRaw, outputRaw] = splitBySection(app, raw)
            % 从单个工作表中按 "Input"/"Output" 节标题拆分数据
            inputRaw = {};
            outputRaw = {};
            currentSection = '';
            startRow = 1;

            for i = 1:size(raw, 1)
                row = raw(i, :);
                % 跳过空行
                if all(cellfun(@(c) app.isBlank(c), row))
                    continue;
                end

                firstCell = row{1};
                if ~ischar(firstCell)
                    % 非字符行，归入当前节
                    if strcmp(currentSection, 'input')
                        inputRaw{end+1} = row; %#ok<AGROW>
                    elseif strcmp(currentSection, 'output')
                        outputRaw{end+1} = row; %#ok<AGROW>
                    end
                    continue;
                end

                cellStr = lower(strtrim(firstCell));
                if any(strcmp(cellStr, {'input', '输入', '输入端口', 'inputs'}))
                    currentSection = 'input';
                    continue;
                elseif any(strcmp(cellStr, {'output', '输出', '输出端口', 'outputs'}))
                    currentSection = 'output';
                    continue;
                end

                % 普通行
                if strcmp(currentSection, 'input')
                    inputRaw{end+1} = row; %#ok<AGROW>
                elseif strcmp(currentSection, 'output')
                    outputRaw{end+1} = row; %#ok<AGROW>
                end
            end

            % 如果没有找到任何节标题，把全部内容当作输入
            if isempty(currentSection) && ~isempty(raw)
                inputRaw = cell(size(raw, 1), 1);
                for i = 1:size(raw, 1)
                    inputRaw{i} = raw(i, :);
                end
            end

            % 转为类似 xlsread 输出的 cell 矩阵
            if ~isempty(inputRaw)
                maxCols = max(cellfun(@(c) length(c), inputRaw));
                padded = cell(length(inputRaw), maxCols);
                for i = 1:length(inputRaw)
                    for j = 1:length(inputRaw{i})
                        padded{i, j} = inputRaw{i}{j};
                    end
                end
                inputRaw = padded;
            end
            if ~isempty(outputRaw)
                maxCols = max(cellfun(@(c) length(c), outputRaw));
                padded = cell(length(outputRaw), maxCols);
                for i = 1:length(outputRaw)
                    for j = 1:length(outputRaw{i})
                        padded{i, j} = outputRaw{i}{j};
                    end
                end
                outputRaw = padded;
            end
        end

        function ports = parsePortTable(app, raw)
            % 解析端口表格数据
            %   raw: cell 矩阵，每行一个端口
            %   格式（由 PortExtractor 生成）:
            %   列A: 序号（跳过）
            %   列B: 端口名称（必填）
            %   列C: 数据类型（可选）
            %   列D: StorageClass（可选，用于 Code Mapping）
            %   列E: Identifier（可选，用于 Code Mapping）
            %   列F: HeaderFile（可选，用于 Code Mapping）
            %   列G: DefinitionFile（可选，用于 Code Mapping）
            ports = {};

            if isempty(raw)
                return;
            end

            % 检测并跳过表头行
            startIdx = 1;
            if size(raw, 1) >= 1 && ischar(raw{1, 1})
                firstWord = lower(strtrim(raw{1, 1}));
                headerWords = {'port', 'name', '端口', '端口名', '端口名称', ...
                    'portname', 'port_name', '信号名', '信号名称', ...
                    '序号', '序列号', '编号'};
                if any(strcmp(firstWord, headerWords))
                    startIdx = 2;
                end
            end

            for i = startIdx:size(raw, 1)
                row = raw(i, :);
                % 跳过空行
                if length(row) < 2 || app.isBlank(row{2})
                    continue;
                end

                % 列B: 端口名称
                portName = strtrim(char(row{2}));
                if isempty(portName)
                    continue;
                end

                % 列C: 数据类型
                portDataType = '';
                if length(row) >= 3 && ~app.isBlank(row{3})
                    if ischar(row{3})
                        portDataType = strtrim(row{3});
                    end
                end

                % 列D: StorageClass
                portStorageClass = '';
                if length(row) >= 4 && ~app.isBlank(row{4})
                    if ischar(row{4})
                        portStorageClass = strtrim(row{4});
                    end
                end

                % 列E: Identifier
                portIdentifier = '';
                if length(row) >= 5 && ~app.isBlank(row{5})
                    if ischar(row{5})
                        portIdentifier = strtrim(row{5});
                    end
                end

                % 列F: HeaderFile
                portHeaderFile = '';
                if length(row) >= 6 && ~app.isBlank(row{6})
                    if ischar(row{6})
                        portHeaderFile = strtrim(row{6});
                    end
                end

                % 列G: DefinitionFile
                portDefinitionFile = '';
                if length(row) >= 7 && ~app.isBlank(row{7})
                    if ischar(row{7})
                        portDefinitionFile = strtrim(row{7});
                    end
                end

                ports{end+1} = struct( ...
                    'name',           portName, ...
                    'dataType',       portDataType, ...
                    'storageClass',   portStorageClass, ...
                    'identifier',     portIdentifier, ...
                    'headerFile',     portHeaderFile, ...
                    'definitionFile', portDefinitionFile); %#ok<AGROW>
            end
        end
    end

    % =====================================================================
    % 工具方法
    % =====================================================================
    methods (Access = private)
        function tf = isBlank(~, val)
            % 判断单元格是否为空或全空白
            if isempty(val)
                tf = true;
            elseif ischar(val) && all(isspace(val))
                tf = true;
            elseif isstring(val) && (val == "" || strtrim(val) == "")
                tf = true;
            else
                tf = false;
            end
        end

        function showError(app, msg)
            app.StatusLabel.FontColor = [0.8, 0.1, 0.1];
            app.StatusLabel.Text = ['✗ ', msg];
        end

        function showWarning(app, msg)
            app.StatusLabel.FontColor = [0.8, 0.6, 0];
            app.StatusLabel.Text = ['⚠ ', msg];
        end
    end
end
