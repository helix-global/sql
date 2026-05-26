using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlSingleCollectionConverter : TypeConverter
        {
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
            if (CheckConstructedGenericCollectionType(destinationType,out var TypeG,out var TypeT)) {
                if ((TypeG == typeof(IList<>)) && (TypeT == typeof(Single))) {
                    var target = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(TypeT));
                    if (value is String S) {
                        foreach (var i in S.Split(new[] {','})) {
                            target.Add((Single)SqlSingleConverter.ConvertFromObject(en,i.Trim()));
                            }
                        }
                    return (IList)Activator.CreateInstance(typeof(ReadOnlyCollection<>).MakeGenericType(TypeT),target);
                    }
                }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:CheckConstructedGenericCollectionType(Type,{out}Type,{out}Type):Boolean
        private static Boolean CheckConstructedGenericCollectionType(Type TypeS,out Type TypeG,out Type TypeT) {
            TypeG = default;
            TypeT = default;
            var typeS = TypeS;
            if (typeS.IsConstructedGenericType) {
                var typeG = typeS.GetGenericTypeDefinition();
                if (typeG == typeof(IList<>)) {
                    TypeG = typeG;
                    TypeT = typeS.GenericTypeArguments[0];
                    return true;
                    }
                return false;
                }
            typeS = TypeS.BaseType;
            if (typeS != null) {
                if (typeS.IsConstructedGenericType) {
                    var typeG = typeS.GetGenericTypeDefinition();
                    if (typeG == typeof(SqlCollection<>)) {
                        TypeG = typeG;
                        TypeT = typeS.GenericTypeArguments[0];
                        return true;
                        }
                    return false;
                    }
                }
            return false;
            }
        #endregion

        private static readonly CultureInfo en = new CultureInfo("en-US");
        }
    }
