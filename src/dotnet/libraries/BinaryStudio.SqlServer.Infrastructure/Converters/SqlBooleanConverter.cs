using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlBooleanConverter : TypeConverter,ISqlValueTypeConverter<Boolean>
        {
        public static readonly SqlBooleanConverter Default          = new SqlBooleanConverter(true);
        public static readonly SqlBooleanConverter DoesNotAllowNull = new SqlBooleanConverter(false);

        public Boolean AllowNull { get; }

        #region ctor{Boolean}
        public SqlBooleanConverter(Boolean AllowNull) {
            this.AllowNull = AllowNull;
            }
        #endregion
        #region ctor
        public SqlBooleanConverter()
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
        #region M:GetStandardValues(ITypeDescriptorContext):StandardValuesCollection
        /// <summary>Returns a collection of standard values for the data type this type converter is designed for when provided with a format context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context that can be used to extract additional information about the environment from which this converter is invoked. This parameter or properties of this parameter can be <see langword="null"/>.</param>
        /// <returns>A <see cref="T:System.ComponentModel.TypeConverter.StandardValuesCollection"/> that holds a standard set of valid values, or <see langword="null"/> if the data type does not support a standard set of values.</returns>
        public override StandardValuesCollection GetStandardValues(ITypeDescriptorContext context)
            {
            return values ?? (values = new StandardValuesCollection(new Object[2] {true, false}));
            }
        #endregion
        #region M:GetStandardValuesExclusive(ITypeDescriptorContext):Boolean
        /// <summary>Returns whether the collection of standard values returned from <see cref="M:System.ComponentModel.TypeConverter.GetStandardValues"/> is an exclusive list of possible values, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <returns><see langword="true"/> if the <see cref="T:System.ComponentModel.TypeConverter.StandardValuesCollection"/> returned from <see cref="M:System.ComponentModel.TypeConverter.GetStandardValues"/> is an exhaustive list of possible values; <see langword="false"/> if other values are possible.</returns>
        public override Boolean GetStandardValuesExclusive(ITypeDescriptorContext context)
            {
            return true;
            }
        #endregion
        #region M:GetStandardValuesSupported(ITypeDescriptorContext):Boolean
        /// <summary>Returns whether this object supports a standard set of values that can be picked from a list, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <returns><see langword="true"/> if <see cref="M:System.ComponentModel.TypeConverter.GetStandardValues"/> should be called to find a common set of values the object supports; otherwise, <see langword="false"/>.</returns>
        public override Boolean GetStandardValuesSupported(ITypeDescriptorContext context)
            {
            return true;
            }
        #endregion
        #region M:ConvertFromObject(Object):Boolean?
        public static Boolean? ConvertFromObject(Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is Boolean B)  { return B; }
            if (value is Int32 SI4)  { return SI4 != 0; }
            if (value is Int64 SI8)  { return SI8 != 0; }
            if (value is SByte SI1)  { return SI1 != 0; }
            if (value is Int16 SI2)  { return SI2 != 0; }
            if (value is Byte  UI1)  { return UI1 != 0; }
            if (value is UInt16 UI2) { return UI2 != 0; }
            if (value is UInt32 UI4) { return UI4 != 0; }
            if (value is UInt64 UI8) { return UI8 != 0; }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            Boolean r;
            if (!Boolean.TryParse(S, out r)) {
                var si8 = SqlInt64Converter.ConvertFromObject(S);
                if (si8 != null) { return si8.Value != 0; }
                return null;
                }
            return r;
            }
        #endregion
        #region M:ConvertFromObject(Object,Boolean):Boolean
        public static Boolean ConvertFromObject(Object value,Boolean defaultValue)
            {
            return ConvertFromObject(value).GetValueOrDefault(defaultValue);
            }
        #endregion
        #region M:ISqlValueTypeConverter<Boolean>.ConvertFromObject(Object):Boolean?
        Boolean? ISqlValueTypeConverter<Boolean>.ConvertFromObject(Object value) {
            return ConvertFromObject(value);
            }
        #endregion
        #region M:ISqlValueTypeConverter<Boolean>.ConvertFromObject(Object,Boolean):Boolean
        Boolean ISqlValueTypeConverter<Boolean>.ConvertFromObject(Object value,Boolean defaultValue)
            {
            return ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"BooleanConverter{{AllowNull={AllowNull}}}";
            }
        #endregion

        private static volatile StandardValuesCollection values;
        }
    }