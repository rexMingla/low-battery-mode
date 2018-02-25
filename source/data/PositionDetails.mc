using Toybox.System;

module data {
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
            var useSmallerFonts = needsSmallFont(dc);

            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = useSmallerFonts ? dc.FONT_SMALL : dc.FONT_NUMBER_MEDIUM;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = useSmallerFonts ? dc.FONT_XTINY : dc.FONT_SMALL;
            details.LabelHeight = dc.getFontHeight(details.LabelFont);
            details.DataAndLabelOffset = getLabelOffset(details.LabelHeight, dc);

            details.CentreColumn = details.Width / 2;
            details.CentreRow = (details.Height - details.DataFont) / 2;
            return details;
        }

        private static function getLabelOffset(labelHeight, dc) {
            return labelHeight + 5;
        }

        private static function needsSmallFont(dc) {
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            // hacky way to get 735xt to use larger fonts than the fenix
            return dc.getFontHeight(dc.FONT_SMALL) > 19;
        }
    }
}