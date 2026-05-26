using System;
using System.CodeDom;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlStringCollectionConverter : TypeConverter
        {
        [TypeConverter(typeof(SqlEnumConverter<StringSplitOptions>))] public StringSplitOptions StringSplitOptions { get;set; }
        [TypeConverter(typeof(OptSplitConverter))] public IList<String> StringSplitSeparator { get;set; } = EmptyArray<String>.List;

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
            if (destinationType == typeof(String)) { return value?.ToString(); }
            if (destinationType == typeof(IList<String>)) {
                var r = new List<String>();
                if (value != null) {
                    var S = value.ToString();
                    if (!String.IsNullOrEmpty(S)) {
                        foreach (var i in S.Split(StringSplitSeparator?.ToArray() ?? new[] {";"," "},StringSplitOptions)) {
                            r.Add(i);
                            }
                        }
                    }
                return r.AsReadOnly();
                }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion

        private class OptSplitConverter : SqlStringCollectionConverter
            {
            public OptSplitConverter()
                {
                StringSplitOptions = StringSplitOptions.RemoveEmptyEntries;
                StringSplitSeparator = new[] {";",","};
                }
            }
        }
    }