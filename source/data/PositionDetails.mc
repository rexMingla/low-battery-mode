using Toybox.System;

module data {
    class FontSets {
        public var DataFont;
        public var LabelFont;

        public function initialize(dataFont, labelFont) {
            DataFont = dataFont;
            LabelFont = labelFont;
        }
    }

    class PositionDetails {
        public var Height;
        public var Width;
        public var DataHeight;
        public var DataFont;
        public var LabelHeight;
        public var LabelFont;
        public var DataAndLabelOffset;

        public var CentreColumn;
        public var CentreRow;

        static function createFromDataContext(dc) {
            var fontSets = getFontSets(dc);

            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = fontSets.DataFont;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = fontSets.LabelFont;
            details.LabelHeight = dc.getFontHeight(details.LabelFont);
            details.DataAndLabelOffset = getLabelOffset(details.LabelHeight, dc);

            details.CentreColumn = details.Width / 2;
            details.CentreRow = (details.Height - details.DataFont) / 2;
            return details;
        }

        private static function getLabelOffset(labelHeight, dc) {
            return labelHeight + 5;
        }

        private static function getFontSets(dc) {
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            // fenix
            if (dc.getWidth() == 240) {
               return new FontSets(dc.FONT_NUMBER_THAI_HOT, dc.FONT_SMALL);
            }
            // hacky way to get 735xt to use larger fonts than the fenix
            if (dc.getFontHeight(dc.FONT_SMALL) > 19) {
                return new FontSets(dc.FONT_SMALL, dc.FONT_XTINY);
            }
            return new FontSets(dc.FONT_NUMBER_MEDIUM, dc.FONT_SMALL);
        }
    }
}