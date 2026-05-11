using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlDateTimeConverter : TypeConverter,ISqlValueTypeConverter<DateTime>
        {
        public static readonly SqlDateTimeConverter Default          = new SqlDateTimeConverter(true);
        public static readonly SqlDateTimeConverter DoesNotAllowNull = new SqlDateTimeConverter(false);

        public Boolean AllowNull { get; }

        #region ctor{Boolean}
        public SqlDateTimeConverter(Boolean AllowNull) {
            this.AllowNull = AllowNull;
            }
        #endregion
        #region ctor
        public SqlDateTimeConverter()
            :this(true)
            {
            }
        #endregion

        #region M:CanConvertFrom(ITypeDescriptorContext,Type):Boolean
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type"/> that represents the type you want to convert from.</param>
        /// <returns><see langword="true"/>if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if ((sourceType == typeof(String)) ||
                (sourceType == typeof(DateTime)))
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
            if (destinationType == typeof(DateTime)) {
                var r = ConvertFromObject(value);
                if ((r == null) && (AllowNull == false)) {
                    throw new InvalidCastException();
                    }
                return r;
                }
            if (destinationType == typeof(DateTime?)) { return ConvertFromObject(value); }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:ConvertFromObject(Object,String[]):DateTime?
        /// <summary>Converts the specified object to a nullable <see cref="T:System.DateTime"/> value using the provided date and time formats.</summary>
        /// <param name="value">The object to convert. Can be a <see cref="T:System.DateTime"/> instance or a string representation of a date and time.</param>
        /// <param name="formats">An array of allowable date and time format strings used to parse the value.</param>
        /// <returns>A <see cref="T:System.DateTime"/> value if the conversion is successful; otherwise, <see langword="null"/>.</returns>
        public static DateTime? ConvertFromObject(Object value,String[] formats) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is DateTime DT)  { return DT; }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            if (!DateTime.TryParseExact(S,formats,CultureInfo.CurrentUICulture,DateTimeStyles.None, out var r)) {
                foreach (var culture in cultures) {
                    if (DateTime.TryParseExact(S,formats,culture,DateTimeStyles.None, out r)) {
                        return r;
                        }
                    var dateTimeFormatInfo = (DateTimeFormatInfo)culture.GetFormat(typeof(DateTimeFormatInfo));
                    if (dateTimeFormatInfo != null) {
                        if (DateTime.TryParse(S,dateTimeFormatInfo,DateTimeStyles.None,out r)) {
                            return r;
                            }
                        }
                    }
                return null;
                }
            return r;
            }
        #endregion
        #region M:ConvertFromObject(Object):DateTime?
        /// <summary>Converts the specified object to a nullable <see cref="T:System.DateTime"/> value, if possible.</summary>
        /// <param name="value">The object to convert. This can be a <see cref="T:System.DateTime"/> instance, a string representation of a date and time, or <see langword="null"/>.</param>
        /// <returns>A <see cref="T:System.DateTime"/> value if the conversion is successful; otherwise, <see langword="null"/>.</returns>
        public static DateTime? ConvertFromObject(Object value) {
            return ConvertFromObject(value,new String[] {
                "s","o",
                "yyyy-MM-dd HH:mm:ss.fff",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd"});
            }
        #endregion
        #region M:ConvertFromObject(Object,DateTime):DateTime
        /// <summary>Converts the specified object to a date-time, or returns a default value if the conversion is not possible.</summary>
        /// <param name="value">The object to convert to a date-time. Can be <see langword="null"/> or any type that can be converted to <see cref="T:System.DateTime"/>.</param>
        /// <param name="defaultValue">The value to return if the conversion is not successful.</param>
        /// <returns>A date-time representing the converted value, or the specified default value if the conversion fails.</returns>
        public static DateTime ConvertFromObject(Object value,DateTime defaultValue)
            {
            return ConvertFromObject(value).GetValueOrDefault(defaultValue);
            }
        #endregion
        #region M:ISqlValueTypeConverter<DateTime>.ConvertFromObject(Object):DateTime?
        DateTime? ISqlValueTypeConverter<DateTime>.ConvertFromObject(Object value) {
            return ConvertFromObject(value);
            }
        #endregion
        #region M:ISqlValueTypeConverter<DateTime>.ConvertFromObject(Object,DateTime):DateTime
        DateTime ISqlValueTypeConverter<DateTime>.ConvertFromObject(Object value,DateTime defaultValue)
            {
            return ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"DateTimeConverter{{AllowNull={AllowNull}}}";
            }
        #endregion

        private static readonly CultureInfo en = new CultureInfo("en-US");
        private static readonly CultureInfo ru = new CultureInfo("ru-RU");
        private static readonly CultureInfo de = new CultureInfo("de-DE");
        private static readonly CultureInfo[] cultures = {en,ru,de };
        }
    }

