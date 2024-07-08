classdef OPreader

    properties (SetAccess = private)

        folder
        index

        PlateName
        MeasurementStartTime
        MeasurementStartTimeLocal

        NumRows
        NumCols
        PlateMap

        WellInfo

    end


    methods

        function obj = OPreader(inputDir)

            %Parse directory to get number of images, rows, cols, etc.
            if nargin == 0
                error('Please specify directory of images.')
            else

                if ~exist(inputDir, 'dir')
                    error('OPreader:DirectoryDoesNotExist', ...
                        'Directory %s does not exist.', inputDir)

                else
                    %Look for the index file
                    if exist(fullfile(inputDir, 'Images', 'Index.idx.xml'), 'file')

                        obj.folder = inputDir;

                    elseif exist(fullfile(inputDir, 'Index.idx.xml'), 'file')

                        fpath = fileparts(inputDir);

                        obj.folder = fpath;

                    else

                        error('OPreader:CannotFindIndex', ...
                        'Could not find Index.idx.xml file in folder %s.', inputDir);
                    end

                    obj = parseMetadataXML(obj);

                end                

            end
        end
    end

    methods (Access = protected)

        function obj = parseMetadataXML(obj)

            %Read in metadata
            fprintf('Reading metadata file... please wait.\n')
            S = readstruct(fullfile(obj.folder, 'Images', 'Index.idx.xml'));

            %Parse the metadata
            obj.PlateName = S.Plates.Plate.Name;
            obj.MeasurementStartTime = S.Plates.Plate.MeasurementStartTime;

            dt = datetime('now', 'TimeZone', 'local');
            tz = dt.TimeZone;
            obj.MeasurementStartTimeLocal = datetime(obj.MeasurementStartTime,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSSSZ','TimeZone',tz);

            obj.NumRows = S.Plates.Plate.PlateRows;
            obj.NumCols = S.Plates.Plate.PlateCols;

            %Gather image information
            imgRows = cat(1, S.Images.Image.Col);
            imgCols = cat(1, S.Images.Image.Col);

            obj.PlateMap = false(obj.NumRows, obj.NumCols);
            obj.WellInfo = struct('Fields', [], 'Planes', [], ...
                'Timepoints', [], 'Channels', [], 'ChannelNames', [], ...
                'Images', []);
            
            %See which wells are populated
            for iWell = 1:numel(S.Plates.Plate.Well)

                %The well ID is converted into a number. First digit (or
                %two digits for 4 digit number) is Row, last two digits are
                %column.

                wellIDstr = sprintf('%04d', S.Plates.Plate.Well(iWell).idAttribute);

                row = str2double(wellIDstr(1:2));
                col = str2double(wellIDstr(3:4));

                obj.PlateMap(row, col) = true;

                %Pull image information
                tmpS = S.Images.Image(imgRows == row && imgCols == col);

                obj.WellInfo(row, col).Fields = unique(cat(1, tmpS.FieldID));
                obj.WellInfo(row, col).Planes = unique(cat(1, tmpS.PlaneID));
                obj.WellInfo(row, col).Timepoints = unique(cat(1, tmpS.TimepointID));
                



            end    

        end

    end


end