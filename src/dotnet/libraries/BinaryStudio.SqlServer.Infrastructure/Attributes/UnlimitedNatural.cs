using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(UnlimitedNaturalTypeConverter))]
    internal struct UnlimitedNatural: IEquatable<UnlimitedNatural>,IEquatable<Int32>,IEquatable<Int64>,IEquatable<UInt32>,IEquatable<UInt64>
        {
        public static readonly UnlimitedNatural Zero = new UnlimitedNatural(0);
        public static readonly UnlimitedNatural One  = new UnlimitedNatural(1);
        public static readonly UnlimitedNatural Unlimited = new UnlimitedNatural(true);

        private UInt64 Value {get;}
        public Boolean IsUnlimited {get;}

        #region ctor{UInt64}
        public UnlimitedNatural(UInt64 source) {
            Value = source;
            IsUnlimited = false;
            }
        #endregion
        #region ctor{Boolean}
        private UnlimitedNatural(Boolean source) {
            Value = 0;
            IsUnlimited = source;
            }
        #endregion

        #region M:ToString:String
        public override String ToString() {
            return IsUnlimited
                ? "*"
                : Value.ToString();
            }
        #endregion
        #region M:Equals(UnlimitedNatural):Boolean
        public Boolean Equals(UnlimitedNatural other) {
            if (IsUnlimited  &&  other.IsUnlimited) { return true;  }
            if (IsUnlimited  && !other.IsUnlimited) { return false; }
            if (!IsUnlimited &&  other.IsUnlimited) { return false; }
            return Value == other.Value;
            }
        #endregion
        #region M:Equals(Int32):Boolean
        public Boolean Equals(Int32 other) {
            return Equals((Int64)other);
            }
        #endregion
        #region M:Equals(Int64):Boolean
        public Boolean Equals(Int64 other) {
            return Equals(unchecked((UInt64)other));
            }
        #endregion
        #region M:Equals(UInt32):Boolean
        public Boolean Equals(UInt32 other) {
            return Equals((UInt64)other);
            }
        #endregion
        #region M:Equals(UInt64):Boolean
        public Boolean Equals(UInt64 other) {
            if (IsUnlimited) { return false;  }
            return Value == other;
            }
        #endregion
        #region M:Equals(UnlimitedNatural,UnlimitedNatural):Boolean
        public static Boolean Equals(UnlimitedNatural x,UnlimitedNatural y) {
            return x.Equals(y);
            }
        #endregion

        public static explicit operator UInt64(UnlimitedNatural source)
            {
            if (source.IsUnlimited) { throw new NotSupportedException(); }
            return source.Value;
            }

        public static Boolean operator ==(UnlimitedNatural x,UnlimitedNatural y)
            {
            return Equals(x,y);
            }

        public static Boolean operator !=(UnlimitedNatural x,UnlimitedNatural y)
            {
            return !Equals(x,y);
            }
        }

    internal class UnlimitedNaturalTypeConverter : TypeConverter
        {
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type"/> that represents the type you want to convert from.</param>
        /// <returns><see langword="true"/> if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if (sourceType == typeof(String)) { return true; }
            if (sourceType == typeof(UnlimitedNatural)) { return true; }
            if (sourceType == typeof(UInt16)) { return true; }
            if (sourceType == typeof(UInt32)) { return true; }
            if (sourceType == typeof(UInt64)) { return true; }
            return base.CanConvertFrom(context, sourceType);
            }

        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture,Object value) {
            if (value is String S) {
                if (S == "*") { return UnlimitedNatural.Unlimited; }
                if (UInt64.TryParse(S,out var UI8)) { return new UnlimitedNatural(UI8); }
                }
            return base.ConvertFrom(context, culture, value);
            }
        }
    }
