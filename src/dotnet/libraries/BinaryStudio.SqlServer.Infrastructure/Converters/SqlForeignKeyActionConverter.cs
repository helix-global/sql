using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlForeignKeyActionConverter : TypeConverter
        {
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type" /> that represents the type you want to convert from.</param>
        /// <returns><see langword="true" />if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context, Type sourceType) {
            if ((sourceType == typeof(String)) ||
                (sourceType == typeof(Int32))  ||
                (sourceType == typeof(Int16))  ||
                (sourceType == typeof(Int64))  ||
                (sourceType == typeof(UInt32)) ||
                (sourceType == typeof(UInt16)) ||
                (sourceType == typeof(UInt64)) ||
                (sourceType == typeof(SByte))  ||
                (sourceType == typeof(Byte))   ||
                (sourceType == typeof(SqlForeignKeyAction)))
                {
                return true;
                }
            return base.CanConvertFrom(context, sourceType);
            }

        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context, CultureInfo culture, Object value)
            {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is SqlForeignKeyAction E) { return E; }
            if (value is Int32  SI4) { return (SqlForeignKeyAction)SI4; }
            if (value is Int64  SI8) { return (SqlForeignKeyAction)(Int32)SI8; }
            if (value is SByte  SI1) { return (SqlForeignKeyAction)(Int32)SI1; }
            if (value is Int16  SI2) { return (SqlForeignKeyAction)(Int32)SI2; }
            if (value is Byte   UI1) { return (SqlForeignKeyAction)(Int32)UI1; }
            if (value is UInt16 UI2) { return (SqlForeignKeyAction)(Int32)UI2; }
            if (value is UInt32 UI4) { return (SqlForeignKeyAction)(Int32)UI4; }
            if (value is UInt64 UI8) { return (SqlForeignKeyAction)(Int32)UI8; }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            if (!Enum.TryParse<SqlForeignKeyAction>(S, out E))
                {
                return null;
                }
            return E;
            }
        }
    }
