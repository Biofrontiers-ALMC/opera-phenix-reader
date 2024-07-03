DOMnode = xmlread('F:\2024 Liu Lab\Duration data + HeCAT21624__2024-02-16T15_55_35-Measurement 1\Images\Index.idx.xml');

% doc = DOMnode.getChildNodes;

import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

expression = xpath.compile('//EvaluationInputData/Plates/Plate/PlateID');
plateIDnode = expression.evaluate(DOMnode, XPathConstants.NODE);
output = plateIDnode.getTextContent