using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlInt16Converter : TypeConverter,ISqlValueTypeConverter<Int16>
        {
        public static readonly SqlInt16Converter Default          = new SqlInt16Converter(true);
        public static readonly SqlInt16Converter DoesNotAllowNull = new SqlInt16Converter(false);

        public Boolean AllowNull { get; }

        #region ctor{Boolean}
        public SqlInt16Converter(Boolean AllowNull) {
            this.AllowNull = AllowNull;
            }
        #endregion
        #region ctor
        public SqlInt16Converter()
            :this(true)
            {
            }
        #endregion

        #region M:CanConvertFrom(ITypeDescriptorContext,Type):Boolean
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type" /> that represents the type you want to convert from.</param>
        /// <returns><see langword="true" />if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if ((sourceType == typeof(String)) ||
                (sourceType == typeof(Int32))  ||
                (sourceType == typeof(Int16))  ||
                (sourceType == typeof(Int64))  ||
                (sourceType == typeof(UInt32)) ||
                (sourceType == typeof(UInt16)) ||
                (sourceType == typeof(UInt64)) ||
                (sourceType == typeof(SByte))  ||
                (sourceType == typeof(Byte)))
                {
                return true;
                }
            return base.CanConvertFrom(context, sourceType);
            }
        #endregion
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture,Object value) {
            var r = ConvertFromObject(value);
            if ((r == null) && (AllowNull == false)) {
                throw new InvalidCastException();
                }
            return r;
            }
        #endregion
        #region M:ConvertFromObject(Object):Int16?
        public static Int16? ConvertFromObject(Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is Boolean B)  { return (Int16)(B ? 1 : 0); }
            if (value is Int32  SI4) { return (Int16)SI4; }
            if (value is Int64  SI8) { return (Int16)SI8; }
            if (value is SByte  SI1) { return (Int16)SI1; }
            if (value is Int16  SI2) { return (Int16)SI2; }
            if (value is Byte   UI1) { return (Int16)UI1; }
            if (value is UInt16 UI2) { return (Int16)UI2; }
            if (value is UInt32 UI4) { return (Int16)UI4; }
            if (value is UInt64 UI8) { return (Int16)UI8; }
            if (value is Enum E) {
                return Convert.ToInt16(E);
                }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            Int16 r;
            if (!Int16.TryParse(S,out r))
                {
                return null;
                }
            return r;
            }
        #endregion
        #region M:ConvertFromObject(Object,Int16):Int16
        public static Int16 ConvertFromObject(Object value,Int16 defaultValue)
            {
            return ConvertFromObject(value).GetValueOrDefault(defaultValue);
            }
        #endregion
        #region M:ISqlValueTypeConverter<Int16>.ConvertFromObject(Object):Int16?
        Int16? ISqlValueTypeConverter<Int16>.ConvertFromObject(Object value) {
            return ConvertFromObject(value);
            }
        #endregion
        #region M:ISqlValueTypeConverter<Int16>.ConvertFromObject(Object,Int16):Int16
        Int16 ISqlValueTypeConverter<Int16>.ConvertFromObject(Object value,Int16 defaultValue)
            {
            return ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"Int16Converter{{AllowNull={AllowNull}}}";
            }
        #endregion
        }
    }
