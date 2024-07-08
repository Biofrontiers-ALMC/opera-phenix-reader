DOMnode = xmlread('F:\2024 Liu Lab\Duration data + HeCAT21624__2024-02-16T15_55_35-Measurement 1\Images\Index.idx.xml');
% 
% % doc = DOMnode.getChildNodes;
% 
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

expression = xpath.compile('//Plates');
plateIDnode = expression.evaluate(DOMnode, XPathConstants.NODE);
output = plateIDnode.getTextContent

% T = readstruct('F:\2024 Liu Lab\Duration data + HeCAT21624__2024-02-16T15_55_35-Measurement 1\Images\Index.idx.xml',...
%     StructSelector="//Plates");

% import matlab.io.xml.xpath.*
% 
% xpExpr = "//PlateRows";
% xmlFilePath = "F:\2024 Liu Lab\Duration data + HeCAT21624__2024-02-16T15_55_35-Measurement 1\Images\Index.idx.xml";
% data = evaluate(Evaluator,xpExpr,xmlFilePath,EvalResultType.NodeSet)
