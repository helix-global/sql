using System;
using System.ComponentModel;
using System.Globalization;
using System.Reflection;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlEnumConverter<E> : TypeConverter,ISqlValueTypeConverter<E>
        where E : struct,Enum
        {
        public static readonly SqlEnumConverter<E> Default          = new SqlEnumConverter<E>(true);
        public static readonly SqlEnumConverter<E> DoesNotAllowNull = new SqlEnumConverter<E>(false);

        public Boolean AllowNull { get; }

        #region ctor{Boolean}
        public SqlEnumConverter(Boolean AllowNull) {
            this.AllowNull = AllowNull;
            }
        #endregion
        #region ctor
        public SqlEnumConverter()
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
                (sourceType == typeof(Byte))   ||
                (sourceType == typeof(Enum))   ||
                (sourceType == typeof(E)))
                {
                return true;
                }
            return base.CanConvertFrom(context, sourceType);
            }
        #endregion
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as thercurrent culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/>rto convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents therconverted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannotrbe performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture, Object value) {
            var r = ConvertFromObject(value);
            if ((r == null) && (AllowNull == false)) {
                throw new InvalidCastException();
                }
            return r;
            }
        #endregion
        #region M:ConvertFromObject(Object):E?
        public static E? ConvertFromObject(Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is E r) { return r; }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            if (Enum.TryParse<E>(S, out r))
                {
                return r;
                }
            if (value is Enum e) {
                var sfi = e.GetType().GetField("value__");
                var tfi = typeof(E).GetField("value__");
                value = sfi.GetValue(e);
                if (tfi.FieldType == sfi.FieldType) { return SetValue(tfi,value); }
                if (tfi.FieldType == typeof(Int16)) { return SetValue(tfi,SqlInt16Converter.ConvertFromObject(value)); }
                if (tfi.FieldType == typeof(Int32)) { return SetValue(tfi,SqlInt32Converter.ConvertFromObject(value)); }
                if (tfi.FieldType == typeof(Int64)) { return SetValue(tfi,SqlInt64Converter.ConvertFromObject(value)); }
                }
            return (E)(Object)SqlInt32Converter.ConvertFromObject(value);
            }
        #endregion
        #region M:ConvertFromObject(Object,E):E
        public static E ConvertFromObject(Object value,E defaultValue)
            {
            return ConvertFromObject(value).GetValueOrDefault(defaultValue);
            }
        #endregion
        #region M:ISqlValueTypeConverter<E>.ConvertFromObject(Object):E?
        E? ISqlValueTypeConverter<E>.ConvertFromObject(Object value) {
            return ConvertFromObject(value);
            }
        #endregion
        #region M:ISqlValueTypeConverter<E>.ConvertFromObject(Object,E):E
        E ISqlValueTypeConverter<E>.ConvertFromObject(Object value,E defaultValue)
            {
            return ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"EnumConverter<{typeof(E).Name}>{{AllowNull={AllowNull}}}";
            }
        #endregion
        #region M:SetValue(FieldInfo,Object):E
        private static E SetValue(FieldInfo fi,Object source) {
            E r = default;
            fi.SetValue(r,source);
            return r;
            }
        #endregion
        }
    }
