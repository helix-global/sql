using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using SqlCodeDomMultipartIdentifier=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlMultipartIdentifier;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal class SqlScriptCodeObject<T> : SqlScriptObject
        where T : SqlCodeObject
        {
        [UsedImplicitly][Field(Source="Sql")] protected String Script { get; }
        protected internal T Source { get; }
        #if DEBUG
        //protected IList<SqlScriptObject> Children { get; } = EmptyArray<SqlScriptObject>.List;
        #endif

        #region ctor{IServiceProvider,T}
        protected SqlScriptCodeObject(IServiceProvider context,T source)
            : base(context,source)
            {
            Source = source;
            if (source != null) {
                //#if DEBUG
                //var children = new List<SqlScriptObject>();
                //foreach (var o in source.Children) {
                //    if (o != null) {
                //        try
                //            {
                //            children.Add(SqlScriptObjectConverter.CreateFrom(context,o));
                //            }
                //        catch (Exception e)
                //            {
                //            e.Add("SelfType",GetType().FullName);
                //            throw;
                //            }
                //        }
                //    }
                //Children = children.AsReadOnly();
                //#endif
                }
            }
        #endregion

        #region M:CoerceValue(Type,TypeConverter,Object):Object
        protected override Object CoerceValue(Type targetType,TypeConverter converter,Object value) {
            if (converter == null) { converter = TypeDescriptor.GetConverter(targetType); }
            if (value is SqlCodeDomMultipartIdentifier CodeDomMultipartIdentifier) {
                var r = SqlObjectIdentifier.Create(CodeDomMultipartIdentifier.Select(i => new SqlIdentifier(i.Value)));
                return base.CoerceValue(targetType,converter,r);
                }
            if (value is SqlCodeObject SqlCodeObject) {
                var r = SqlScriptObjectConverter.CreateFrom(Context,SqlCodeObject);
                return base.CoerceValue(targetType,converter,r);
                }
            if (value != null) {
                CheckConstructedGenericCollectionType(value.GetType(),out var typeGS,out var typeTS);
                CheckConstructedGenericCollectionType(targetType,out var typeGP,out var typeTP);
                if ((typeGS == typeof(SqlCollection<>)) && (typeGP == typeof(IList<>))) {
                    var target = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(typeTP));
                    var source = (IEnumerable)value;
                    foreach (SqlCodeObject i in source) {
                        target.Add(CoerceValue(typeTP,null,SqlScriptObjectConverter.CreateFrom(Context,i)));
                        }
                    return (IList)Activator.CreateInstance(typeof(ReadOnlyCollection<>).MakeGenericType(typeTP),target);
                    }
                }
            return base.CoerceValue(targetType,converter,value);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{{{typeof(T).Name}}}";
            }
        #endregion
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
        }
    }