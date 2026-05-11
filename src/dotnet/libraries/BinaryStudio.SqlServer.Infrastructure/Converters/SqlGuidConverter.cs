using System;
using System.ComponentModel;
using System.ComponentModel.Design.Serialization;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlGuidConverter: TypeConverter,ISqlValueTypeConverter<Guid>
        {
        public static readonly SqlGuidConverter Default          = new SqlGuidConverter(true);
        public static readonly SqlGuidConverter DoesNotAllowNull = new SqlGuidConverter(false);

        public Boolean AllowNull { get; }

        #region ctor{Boolean}
        public SqlGuidConverter(Boolean AllowNull) {
            this.AllowNull = AllowNull;
            }
        #endregion
        #region ctor
        public SqlGuidConverter()
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
                (sourceType == typeof(Guid)))
                {
                return true;
                }
            return base.CanConvertFrom(context, sourceType);
            }
        #endregion
        #region M:CanConvertTo(ITypeDescriptorContext,Type):Boolean
        /// <summary>Gets a value indicating whether this converter can convert an object to the given destination type using the context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="destinationType">A <see cref="T:System.Type"/> that represents the type you wish to convert to.</param>
        /// <returns><see langword="true"/> if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertTo(ITypeDescriptorContext context,Type destinationType) {
            if (destinationType == typeof(InstanceDescriptor))
                {
                return true;
                }
            return base.CanConvertTo(context, destinationType);
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
            if (destinationType == typeof(Guid)) {
                var r = ConvertFromObject(value);
                if ((r == null) && (AllowNull == false)) {
                    throw new InvalidCastException();
                    }
                return r;
                }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:ConvertFromObject(Object):Guid?
        /// <summary>Converts the specified object to a nullable GUID value, if possible.</summary>
        /// <param name="value">The object to convert. Can be a <see cref="T:System.Guid"/>, a string representation of a GUID, or another object whose string representation is a valid GUID. Can be <see langword="null"/>.</param>
        /// <returns>A <see cref="T:System.Guid"/> value if the conversion is successful; otherwise, <see langword="null"/>.</returns>
        public static Guid? ConvertFromObject(Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is Guid G)  { return G;  }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            if (Guid.TryParse(S,out G))  { return G;    }
            return null;
            }
        #endregion
        #region M:ConvertFromObject(Object,Guid):Guid
        /// <summary>Converts the specified object to a GUID value, or returns the specified default value if the conversion is not possible.</summary>
        /// <param name="value">The object to convert to a GUID. Can be <see langword="null"/> or any object that represents a GUID value.</param>
        /// <param name="defaultValue">The GUID value to return if the conversion of the object is not successful.</param>
        /// <returns>A GUID that represents the converted value of the object, or the specified default value if the conversion fails.</returns>
        public static Guid ConvertFromObject(Object value,Guid defaultValue)
            {
            return ConvertFromObject(value).GetValueOrDefault(defaultValue);
            }
        #endregion
        #region M:ISqlValueTypeConverter<Guid>.ConvertFromObject(Object):Guid?
        Guid? ISqlValueTypeConverter<Guid>.ConvertFromObject(Object value) {
            return ConvertFromObject(value);
            }
        #endregion
        #region M:ISqlValueTypeConverter<Guid>.ConvertFromObject(Object,Guid):Guid
        Guid ISqlValueTypeConverter<Guid>.ConvertFromObject(Object value,Guid defaultValue)
            {
            return ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"GuidConverter{{AllowNull={AllowNull}}}";
            }
        #endregion
        }
    }
