using System;
using System.Text.RegularExpressions;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class Multiplicity
        {
        public UInt64 Lower { get; }
        public UnlimitedNatural Upper { get; }
        public Boolean IsMultiple { get {
            if (Upper.IsUnlimited)   { return true;  }
            if (Upper.Equals(Lower)) { return false; }
            if ((Lower == 0) && (Upper == UnlimitedNatural.One)) { return false; }
            return true;
            }}

        #region ctor{Int32,UnlimitedNatural}
        public Multiplicity(Int32 lower,UnlimitedNatural upper)
            {
            if (lower < 0) { throw new ArgumentOutOfRangeException(nameof(lower)); }
            Lower = (UInt64)lower;
            Upper = upper;
            }
        #endregion
        #region ctor{Int32}
        public Multiplicity(Int32 LowerAndUpper)
            {
            if (LowerAndUpper < 0) { throw new ArgumentOutOfRangeException(nameof(LowerAndUpper)); }
            Lower = (UInt64)LowerAndUpper;
            Upper = new UnlimitedNatural(Lower);
            }
        #endregion
        #region ctor{String}
        public Multiplicity(String multiplicity)
            {
            if (multiplicity == null) { throw new ArgumentNullException(nameof(multiplicity)); }
            var r = Parse(multiplicity);
            Lower = r.Lower;
            Upper = r.Upper;
            }
        #endregion

        #region M:Parse(String):Multiplicity
        public static Multiplicity Parse(String source) {
            if (!String.IsNullOrWhiteSpace(source)) {
                source = source.Trim();
                switch (source) {
                    case "0..*": { return new Multiplicity(0,UnlimitedNatural.Unlimited); }
                    case "1..*": { return new Multiplicity(1,UnlimitedNatural.Unlimited); }
                    case "0..1": { return new Multiplicity(0,UnlimitedNatural.One); }
                    case "1..1": { return new Multiplicity(1,UnlimitedNatural.One); }
                    case "1": { return new Multiplicity(1,UnlimitedNatural.One);       }
                    case "*": { return new Multiplicity(0,UnlimitedNatural.Unlimited); }
                    }
                if (IsMatch(source,@"^(\d+)[.][.][*]$",out var match)) { return new Multiplicity(Int32.Parse(match.Groups[1].Value),UnlimitedNatural.Unlimited); }
                if (IsMatch(source,@"^(\d+)$",out match)) { return new Multiplicity(Int32.Parse(match.Groups[1].Value)); }
                if (IsMatch(source,@"^(\d+)[.][.](\d+)$",out match))   { return new Multiplicity(Int32.Parse(match.Groups[1].Value),new UnlimitedNatural(UInt64.Parse(match.Groups[2].Value))); }
                }
            return null;
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            return $"{Lower}..{Upper}";
            }
        #endregion
        #region M:IsMatch(String,String):Boolean
        private static Boolean IsMatch(String input,String pattern)
            {
            return Regex.IsMatch(input,pattern);
            }
        #endregion
        #region M:IsMatch(String,String,{out}Match):Boolean
        private static Boolean IsMatch(String input,String pattern,out Match match)
            {
            match = Regex.Match(input,pattern);
            return match.Success;
            }
        #endregion
        }
    }
