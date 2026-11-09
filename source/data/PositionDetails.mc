import Toybox.Lang;
import Toybox.Graphics;

module data {
    class FontSets {
        public var DataFont as Graphics.FontType;
        public var LabelFont as Graphics.FontType;

        public function initialize(dataFont as Graphics.FontType, labelFont as Graphics.FontType) {
            DataFont = dataFont;
            LabelFont = labelFont;
        }
    }

    class PositionDetails {
        public var Height as Number = 0;
        public var Width as Number = 0;
        public var DataHeight as Number = 0;
        public var DataFont as Graphics.FontType = Graphics.FONT_SMALL;
        public var LabelHeight as Number = 0;
        public var LabelFont as Graphics.FontType = Graphics.FONT_XTINY;
        public var DataAndLabelOffset as Number = 0;

        public var CentreColumn as Number = 0;
        public var CentreRow as Number = 0;

        static function createFromDataContext(dc as Graphics.Dc) as PositionDetails {
            var fontSets = getFontSets(dc);

            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = fontSets.DataFont;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = fontSets.LabelFont;
            details.LabelHeight = dc.getFontHeight(details.LabelFont);
            details.DataAndLabelOffset = getLabelOffset(details.LabelHeight);

            details.CentreColumn = details.Width / 2;
            // top of the value text, so that the value is vertically centred
            details.CentreRow = (details.Height - details.DataHeight) / 2;
            return details;
        }

        private static function getLabelOffset(labelHeight as Number) as Number {
            return labelHeight + 5;
        }

        private static function getFontSets(dc as Graphics.Dc) as FontSets {
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            // fenix
            if (dc.getWidth() == 240) {
               return new FontSets(Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_SMALL);
            }
            // hacky way to get 735xt to use larger fonts than the fenix
            if (dc.getFontHeight(Graphics.FONT_SMALL) > 19) {
                return new FontSets(Graphics.FONT_SMALL, Graphics.FONT_XTINY);
            }
            return new FontSets(Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_SMALL);
        }
    }
}