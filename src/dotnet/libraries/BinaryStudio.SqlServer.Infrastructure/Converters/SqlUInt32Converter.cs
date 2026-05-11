using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using DColor = System.Drawing.Color;
    using MColor = System.Windows.Media.Color;

    internal class SqlUInt32Converter : TypeConverter,ISqlValueTypeConverter<UInt32>
        {
        public static readonly SqlUInt32Converter Default          = new SqlUInt32Converter(true);
        public static readonly SqlUInt32Converter DoesNotAllowNull = new SqlUInt32Converter(false);

        public Boolean AllowNull { get; }

        #region ctor{Boolean}
        public SqlUInt32Converter(Boolean AllowNull) {
            this.AllowNull = AllowNull;
            }
        #endregion
        #region ctor
        public SqlUInt32Converter()
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
        #region M:ConvertTo(ITypeDescriptorContext,CultureInfo,Object,Type):Object
        /// <summary>Converts the given value object to the specified type, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/>. If <see langword="null"/> is passed, the current culture is assumed.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <param name="destinationType">The <see cref="T:System.Type"/> to convert the <paramref name="value"/> parameter to.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.ArgumentNullException">The <paramref name="destinationType"/> parameter is <see langword="null"/>.</exception>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertTo(ITypeDescriptorContext context,CultureInfo culture,Object value,Type destinationType) {
            if (destinationType == null) { throw new ArgumentNullException(nameof(destinationType)); }
            if (destinationType == typeof(UInt32)) {
                var r = ConvertFromObject(value);
                if ((r == null) && (AllowNull == false)) {
                    throw new InvalidCastException();
                    }
                return r;
                }
            if (destinationType == typeof(UInt32?)) { return ConvertFromObject(value); }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:ConvertFromObject(Object):UInt32?
        /// <summary>Converts the specified object to a nullable 32-bit unsigned integer.</summary>
        /// <param name="value">The object to convert. Can be a numeric type, a <see cref="T:System.Boolean"/>, an <see cref="T:System.Enum"/>, or a string representation of a number. Can also be <see langword="null"/> or <see cref="T:System.DBNull"/>.</param>
        /// <returns>A 32-bit unsigned integer value equivalent to the input object, or <see langword="null"/> if the conversion is not possible or the input is <see langword="null"/>, <see cref="T:System.DBNull"/>, or an empty string.</returns>
        public static UInt32? ConvertFromObject(Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is Boolean B)  { return B ? 1U : 0U;  }
            if (value is Int32  SI4) { return unchecked((UInt32)SI4); }
            if (value is Int64  SI8) { return unchecked((UInt32)(Int32)SI8); }
            if (value is SByte  SI1) { return unchecked((UInt32)(Int32)SI1); }
            if (value is Int16  SI2) { return unchecked((UInt32)(Int32)SI2); }
            if (value is Byte   UI1) { return (UInt32)UI1; }
            if (value is UInt16 UI2) { return (UInt32)UI2; }
            if (value is UInt32 UI4) { return (UInt32)UI4; }
            if (value is UInt64 UI8) { return (UInt32)UI8; }
            if (value is MColor MC)  { return unchecked((UInt32)((MC.A << 24) | (MC.R << 16) | (MC.G << 8) | MC.B)); }
            if (value is Enum E) {
                return Convert.ToUInt32(E);
                }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            if (UInt32.TryParse(S,out var ur)) { return ur; }
            if (Int32.TryParse(S,out var sr))  { return unchecked((UInt32)sr); }
            return null;
            }
        #endregion
        #region M:ConvertFromObject(Object,UInt32):UInt32
        /// <summary>Converts the specified object to a 32-bit unsigned integer, or returns a default value if the conversion is not possible.</summary>
        /// <param name="value">The object to convert to a 32-bit unsigned integer. Can be <see langword="null"/> or any type that can be converted to <see cref="T:System.UInt32"/>.</param>
        /// <param name="defaultValue">The value to return if the conversion is not successful.</param>
        /// <returns>A 32-bit unsigned integer representing the converted value, or the specified default value if the conversion fails.</returns>
        public static UInt32 ConvertFromObject(Object value,UInt32 defaultValue)
            {
            return ConvertFromObject(value).GetValueOrDefault(defaultValue);
            }
        #endregion
        #region M:ISqlValueTypeConverter<UInt32>.ConvertFromObject(Object):UInt32?
        UInt32? ISqlValueTypeConverter<UInt32>.ConvertFromObject(Object value) {
            return ConvertFromObject(value);
            }
        #endregion
        #region M:ISqlValueTypeConverter<UInt32>.ConvertFromObject(Object,UInt32):UInt32
        UInt32 ISqlValueTypeConverter<UInt32>.ConvertFromObject(Object value,UInt32 defaultValue)
            {
            return ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"Int32Converter{{AllowNull={AllowNull}}}";
            }
        #endregion
        }
    }
