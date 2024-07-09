classdef OPreader

    properties (SetAccess = private)

        folder
        index

        PlateName
        MeasurementStartTime
        MeasurementStartTimeLocal
       
        PlateMap

        ImageInfo

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
    
        function I = readImage(obj, row, col, channel, timepoint)

            imageIdx = [obj.ImageInfo.Row] == row & ...
                [obj.ImageInfo.Col] == col & ...
                [obj.ImageInfo.ChannelID] == channel & ...
                [obj.ImageInfo.TimepointID] == (timepoint - 1) & ...
                [obj.ImageInfo.FieldID] == 1 & ...
                [obj.ImageInfo.PlaneID] == 1;

            if nnz(imageIdx) == 0

                error('OPreader:readImage:InvalidImageCoordinate', ...
                    'Image at the specified coordinate does not exist.')

            elseif nnz(imageIdx) > 1

                error('OPreader:readImage:ImageCoordinateNotUnique', ...
                    'Multiple images were found at the specified coordinate.')

            end

            I = imread(fullfile(obj.folder, 'Images', obj.ImageInfo(imageIdx).URL));
            
        end

        function imshow(obj, row, col, timepoint)

            Inucl = readImage(obj, row, col, 1, timepoint);
            Icell = readImage(obj, row, col, 2, timepoint);

            Inucl = double(Inucl);
            Inucl = (Inucl - min(Inucl(:)))/(max(Inucl(:)) - min(Inucl(:)));

            Icell = double(Icell);
            Icell = (Icell - min(Icell(:)))/(max(Icell(:)) - min(Icell(:)));

            Irgb = cat(3, Inucl, Icell, zeros(size(Inucl), 'double'));

            imshow(Irgb)
        end

        function exportVideo(obj, row, col, channel, varargin)
            %EXPORTVIDEO  Export video
            %
            %  EXPORTVIDEO(OBJ, ROW, COL, CHANNEL)

            if ~isempty(varargin)
                outputFN = varargin{1};
            else
                outputFN = 'export.avi';
            end

            %Check if output folder exists
            fpath = fileparts(outputFN);

            if ~exist(fpath, 'dir') && ~isempty(fpath)
                mkdir(fpath);
            end

            %Get number of timepoints
            s = unique(cat(1, obj.ImageInfo([obj.ImageInfo.Row] == row & [obj.ImageInfo.Col] == col).TimepointID));

            vid = VideoWriter(outputFN);
            open(vid)

            for iT = 1:numel(s)

                I = readImage(obj, row, col, channel, iT);

                I = double(I);
                I = (I - min(I(:)))/(max(I(:)) - min(I(:)));
                
                writeVideo(vid, I);

            end
            close(vid)

        end

        function wellInfo = getWellInfo(obj, row, col)

            if ~obj.PlateMap(row, col)
                error('OPreader:getWellInfo:NoImagesInWell', ...
                    'Specified well does not contain images.')
            end

            %Get well data
            s = obj.ImageInfo([obj.ImageInfo.Row] == row & [obj.ImageInfo.Col] == col);

            wellInfo.NumImages = numel(s);
            wellInfo.NumFields = numel(unique([s.FieldID]));
            wellInfo.NumPlanes = numel(unique([s.PlaneID]));
            wellInfo.NumTimepoints = numel(unique([s.TimepointID]));
            wellInfo.NumChannels = numel(unique([s.ChannelID]));

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

            %Gather image information
            imgLoc = [cat(1, S.Images.Image.Row) cat(1, S.Images.Image.Col)];

            obj.PlateMap = false(S.Plates.Plate.PlateRows, S.Plates.Plate.PlateColumns);
            
            %Pull image information
            obj.ImageInfo = S.Images.Image;

            %Populate some overview data
            wellLocs = unique(imgLoc, 'rows');

            for iLoc = 1:size(wellLocs, 1)
                obj.PlateMap(wellLocs(iLoc, 1), wellLocs(iLoc, 2)) = true;
            end
            

            % 
            % %See which wells are populated
            % for iWell = 1:numel(S.Plates.Plate.Well)
            % 
            %     %The well ID is converted into a number. First digit (or
            %     %two digits for 4 digit number) is Row, last two digits are
            %     %column.
            % 
            %     wellIDstr = sprintf('%04d', S.Plates.Plate.Well(iWell).idAttribute);
            % 
            %     row = str2double(wellIDstr(1:2));
            %     col = str2double(wellIDstr(3:4));
            % 
            %     obj.PlateMap(row, col) = true;
            % 
            %     %Pull image information
            %     tmpS = S.Images.Image(imgRows == row & imgCols == col);
            % 
            %     obj.WellInfo(iWell).ImageInfo.URL = tmpS.URL;
            %     obj.WellInfo(iWell).ImageInfo.FieldID = tmpS.FieldID;
            %     obj.WellInfo(iWell).ImageInfo.PlaneID = tmpS.PlaneID;
            %     obj.WellInfo(iWell).ImageInfo.TimepointID = tmpS.TimepointID;
            %     obj.WellInfo(iWell).ImageInfo.ChannelID = tmpS.ChannelID;
            %     obj.WellInfo(iWell).ImageInfo.ChannelNames = tmpS.ChannelName;
            % 
            %     obj.WellInfo(iWell).Row = row;
            %     obj.WellInfo(iWell).Col = col;
            %     obj.WellInfo(iWell).Fields = unique(cat(1, tmpS.FieldID));
            %     obj.WellInfo(iWell).Planes = unique(cat(1, tmpS.PlaneID));
            %     obj.WellInfo(iWell).Timepoints = unique(cat(1, tmpS.TimepointID));
            %     obj.WellInfo(iWell).Channels = unique(cat(1, tmpS.ChannelID));
            %     obj.WellInfo(iWell).ChannelNames = unique(cat(1, tmpS.ChannelName));
            % 
            % end    

        end

    end


end