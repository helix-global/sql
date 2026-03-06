using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Threading;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptObjectConverter : TypeConverter
        {
        #region M:CreateFrom(IServiceProvider,SqlCodeObject):SqlScriptCodeObject
        internal static SqlScriptCodeObject CreateFrom(IServiceProvider context,SqlCodeObject source) {
            if (source != null) {
                var rt = source.GetType();
                Type type;
                using (SqlModelObject.UpgradeableReadLock(g_rtlock)) {
                    if (!g_rtlist.TryGetValue(rt, out type)) {
                        foreach (var pair in g_rtlist) {
                            if (pair.Key.IsAssignableFrom(rt)) {
                                using (SqlModelObject.WriteLock(g_rtlock)) 
                                    {
                                    g_rtlist[rt] = type = pair.Value;
                                    }
                                }
                            }
                        }
                    }
                if (type != null) {
                    var ctor = type.GetConstructor(new[] { typeof(IServiceProvider),source.GetType() });
                    if (ctor != null) {
                        return (SqlScriptCodeObject)ctor.Invoke(new Object[] { context,source });
                        }
                    }
                throw (new ArgumentOutOfRangeException(nameof(source), $@"No registered type for ""{source.GetType()}""."))
                    .Add("SourceType",source.GetType().FullName);
                }
            return null;
            }
        #endregion
        #region M:CanConvertFrom(ITypeDescriptorContext,Type):Boolean
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type" /> that represents the type you want to convert from.</param>
        /// <returns><see langword="true" />if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if (sourceType == null) { return false; }
            if (typeof(SqlCodeObject).IsAssignableFrom(sourceType)) { return true; }
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
            if (value is SqlCodeObject SqlCodeObject) { return CreateFrom(context,SqlCodeObject); }
            return base.ConvertFrom(context, culture, value);
            }
        #endregion

        #region sctor
        static SqlScriptObjectConverter() {
            foreach (var type in typeof(SqlScriptCodeObject).Assembly.GetTypes()) {
                var attributes = type.GetCustomAttributes<SqlScriptObjectAttribute>().ToArray();
                if (attributes.Length > 0) {
                    foreach (var attribute in attributes) {
                        try
                            {
                            if (attribute.Type != null)
                                {
                                g_rtlist.Add(attribute.Type,type);
                                continue;
                                }
                            if (String.IsNullOrWhiteSpace(attribute.TypeName))
                                {
                                throw new InvalidOperationException();
                                }
                            var assembly = typeof(SqlCodeObject).Assembly;
                            var typename = attribute.TypeName;
                            var rt = assembly.GetType(typename,false);
                            if (rt != null) {
                                g_rtlist.Add(rt,type);
                                continue;
                                }
                            var values = typename.Split('.');
                            typename = String.Join(".",values.Take(values.Length-1));
                            rt = assembly.GetType(typename,false);
                            if (rt != null) {
                                rt = rt.GetNestedType(values[values.Length-1],BindingFlags.NonPublic|BindingFlags.Public);
                                if (rt != null) {
                                    g_rtlist.Add(rt,type);
                                    continue;
                                    }
                                }
                            throw new InvalidOperationException();
                            }
                        catch
                            {
                            throw;
                            }
                        }
                    }
                }
            }
        #endregion

        protected static readonly IDictionary<Type, Type> g_rtlist = new ConcurrentDictionary<Type, Type>();
        private static readonly ReaderWriterLockSlim g_rtlock = new ReaderWriterLockSlim();
        }
    }
