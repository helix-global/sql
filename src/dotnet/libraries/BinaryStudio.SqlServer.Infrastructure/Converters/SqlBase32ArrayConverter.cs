using System;
using System.ComponentModel;
using System.Globalization;
using System.Runtime.InteropServices;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlBase32ArrayConverter : TypeConverter,ISqlArrayConverter
        {
        public static readonly SqlBase32ArrayConverter Default = new SqlBase32ArrayConverter();

        #region ctor
        public SqlBase32ArrayConverter() {
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
                (sourceType == typeof(Byte[])))
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
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is Byte[]  A)  { return A; }
            if (value is Boolean B)  { return ConvertFrom(B ? (Byte)1 : (Byte)0); }
            if (value is Int32  SI4) { return ConvertFrom(SI4); }
            if (value is Int64  SI8) { return ConvertFrom(SI8); }
            if (value is SByte  SI1) { return ConvertFrom(SI1); }
            if (value is Int16  SI2) { return ConvertFrom(SI2); }
            if (value is Byte   UI1) { return ConvertFrom(UI1); }
            if (value is UInt16 UI2) { return ConvertFrom(UI2); }
            if (value is UInt32 UI4) { return ConvertFrom(UI4); }
            if (value is UInt64 UI8) { return ConvertFrom(UI8); }
            return ConvertFrom((value.ToString()).Trim());
            }
        #endregion
        #region M:ConvertFrom<T>(T):Byte[]
        private static Byte[] ConvertFrom<T>(T value)
            where T:struct
            {
            var r = new Byte[Marshal.SizeOf<T>()];
            var o = GCHandle.Alloc(r,GCHandleType.Pinned);
            try
                {
                Marshal.StructureToPtr(value,o.AddrOfPinnedObject(),false);
                }
            finally
                {
                o.Free();
                }
            return r;
            }
        #endregion
        #region M:ConvertFrom(String):Byte[]
        private Byte[] ConvertFrom(String value) {
            if (String.IsNullOrEmpty(value)) { return null; }
            if (value.StartsWith("0x",StringComparison.OrdinalIgnoreCase)) {
                value = value.Substring(2);
                }
            var c = value.Length;
            if (c % 2 != 0) {
                throw new ArgumentOutOfRangeException();
                }
            c = (c / 2);
            var r = new Byte[c];
            for (var i = 0; i < c; i++) {
                r[i] = Byte.Parse(value.Substring(i * 2, 2),NumberStyles.HexNumber,CultureInfo.InvariantCulture);
                }
            return r;
            }
        #endregion
        #region M:TryConvertFrom(Object,out Byte[]):Boolean
        public Boolean TryConvertFrom(Object value,out Byte[] result) {
            result = null;
            if ((value == null) || (value is DBNull)) { return false; }
            if (value is Byte[] A) { result = A; return true; }
            var s = value.ToString().Trim();
            if (String.IsNullOrEmpty(s)) { return false; }
            if (s.StartsWith("0x",StringComparison.OrdinalIgnoreCase)) {
                s = s.Substring(2);
                }
            var c = s.Length;
            if (c % 2 != 0) {
                return false;
                }
            c = (c / 2);
            var r = new Byte[c];
            for (var i = 0; i < c; i++) {
                r[i] = Byte.Parse(s.Substring(i * 2, 2),NumberStyles.HexNumber,CultureInfo.InvariantCulture);
                }
            result = r;
            return true;
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            return $"Base32ArrayConverter";
            }
        #endregion
        }
    }
