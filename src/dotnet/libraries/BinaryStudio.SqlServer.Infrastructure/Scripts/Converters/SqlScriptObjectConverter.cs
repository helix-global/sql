using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Threading;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptObjectConverter : TypeConverter
        {
        #region M:CreateFrom(IServiceProvider,TSqlFragment):SqlScriptObject
        internal static SqlScriptObject CreateFrom(IServiceProvider context,TSqlFragment source) {
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
                        return (SqlScriptObject)ctor.Invoke(new Object[] { context,source });
                        }
                    }
                throw (new ArgumentOutOfRangeException(nameof(source), $@"No registered type for ""{source.GetType()}""."))
                    .Add("SourceType",source.GetType().FullName);
                }
            return null;
            }
        #endregion
        #region M:CreateFrom(IServiceProvider,SqlCodeObject):SqlScriptObject
        internal static SqlScriptObject CreateFrom(IServiceProvider context,SqlCodeObject source) {
            if (source != null) {
                var rt = source.GetType();
                Type type;
                using (SqlModelObject.UpgradeableReadLock(g_rtlock)) {
                    if (!g_rtlist.TryGetValue(rt, out type)) {
                        //foreach (var pair in g_rtlist) {
                        //    if (pair.Key.IsAssignableFrom(rt)) {
                        //        using (SqlModelObject.WriteLock(g_rtlock)) 
                        //            {
                        //            g_rtlist[rt] = type = pair.Value;
                        //            }
                        //        }
                        //    }
                        }
                    }
                if (type != null) {
                    var ctor = type.GetConstructor(new[] { typeof(IServiceProvider),source.GetType() });
                    if (ctor != null) {
                        var r = (SqlScriptObject)ctor.Invoke(new Object[] { context,source });
                        if (r is SqlScriptNullStatement NullStatement) {
                            if (g_splist.TryGetValue(NullStatement.StatementPhrase,out type)) {
                                ctor = type.GetConstructor(new[] { typeof(IServiceProvider),source.GetType() });
                                if (ctor != null) {
                                    r = ((SqlScriptFactoryStatement)ctor.Invoke(new Object[] { context,source })).Statements[0];
                                    }
                                }
                            else
                                {
                                throw (new ArgumentOutOfRangeException(nameof(source), $@"No registered type for statement phrase ""{NullStatement.StatementPhrase}""."))
                                    .Add("StatementPhrase", NullStatement.StatementPhrase);
                                }
                            }
                        return r;
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
            if (value is TSqlFragment  SqlFragment)   { return CreateFrom(context,SqlFragment);   }
            return base.ConvertFrom(context, culture, value);
            }
        #endregion

        #region sctor
        static SqlScriptObjectConverter() {
            foreach (var type in typeof(SqlScriptObject).Assembly.GetTypes()) {
                var rtA = type.GetCustomAttributes<SqlScriptObjectAttribute>(false).ToArray();
                if (rtA.Length > 0) {
                    foreach (var attribute in rtA) {
                        if (attribute.Type != null)
                            {
                            try
                                {
                                g_rtlist.Add(attribute.Type,type);
                                }
                            catch(Exception e)
                                {
                                e.Add("Key",attribute.Type.FullName);
                                e.Add("PrevValue",g_rtlist[attribute.Type]);
                                throw;
                                }
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
                    }
                var spA = type.GetCustomAttributes<SqlScriptObjectStatementPhraseAttribute>().ToArray();
                if (spA.Length > 0) {
                    foreach (var attribute in spA) {
                        try
                            {
                            if (!String.IsNullOrWhiteSpace(attribute.StatementPhrase))
                                {
                                g_splist.Add(attribute.StatementPhrase,type);
                                continue;
                                }
                            throw new InvalidOperationException();
                            }
                        catch(Exception e)
                            {
                            e.Add("Key",attribute.StatementPhrase);
                            e.Add("PrevValue",g_splist[attribute.StatementPhrase]);
                            throw;
                            }
                        }
                    }
                }
            }
        #endregion

        private class TypeComparer : IComparer<Type>
            {
            public static readonly IComparer<Type> Instance = new TypeComparer();

            #region M:Compare(Type,Type):Int32
            public Int32 Compare(Type x,Type y)
                {
                if (ReferenceEquals(x,y)) { return 0; }
                if (ReferenceEquals(x,null)) { return -1; }
                if (ReferenceEquals(y,null)) { return +1; }
                return x.FullName.CompareTo(y.FullName);
                }
            #endregion
            }

        #if DEBUG
        protected static readonly IDictionary<Type,Type>   g_rtlist = new SortedDictionary<Type,Type>(TypeComparer.Instance);
        protected static readonly IDictionary<String,Type> g_splist = new SortedDictionary<String,Type>(StringComparer.OrdinalIgnoreCase);
        #else
        protected static readonly IDictionary<Type,Type>   g_rtlist = new ConcurrentDictionary<Type,Type>();
        protected static readonly IDictionary<String,Type> g_splist = new ConcurrentDictionary<String,Type>();
        #endif
        private static readonly ReaderWriterLockSlim g_rtlock = new ReaderWriterLockSlim();
        }
    }
