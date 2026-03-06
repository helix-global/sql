using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptCodeObject<T> : SqlScriptCodeObject
        where T : SqlCodeObject
        {
        protected T Source { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptCodeObject(IServiceProvider context,T source)
            : base(context,source)
            {
            Source = source;
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
        }

    [TypeConverter(typeof(SqlScriptObjectConverter))]
    internal class SqlScriptCodeObject : SqlModelObject
        {
        #if DEBUG
        protected IList<SqlScriptCodeObject> Children { get; } = Array.Empty<SqlScriptCodeObject>();
        #endif

        #region ctor{IServiceProvider,SqlCodeObject}
        protected SqlScriptCodeObject(IServiceProvider context,SqlCodeObject source)
            : base(context,source)
            {
            if (source != null) {
                #if DEBUG
                var children = new List<SqlScriptCodeObject>();
                foreach (var o in source.Children) {
                    if (o != null) {
                        try
                            {
                            children.Add(CreateObject(context, o));
                            }
                        catch (Exception e)
                            {
                            e.Add("SelfType",GetType().FullName);
                            throw;
                            }
                        }
                    }
                Children = children.AsReadOnly();
                #endif
                }
            }
        #endregion

        #region M:CoerceValue(Type,TypeConverter,Object):Object
        protected override Object CoerceValue(Type targetType,TypeConverter converter,Object value) {
            if (converter == null) { converter = TypeDescriptor.GetConverter(targetType); }
            if (value is SqlCodeObject SqlCodeObject) {
                var r = CreateObject(Context,SqlCodeObject);
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
        #region M:CreateObject(IServiceProvider,SqlCodeObject):SqlScriptCodeObject
        private static SqlScriptCodeObject CreateObject(IServiceProvider context,SqlCodeObject source)
            {
            return SqlScriptObjectConverter.CreateFrom(context, source);
            }
        #endregion
        //#region M:IsGenericCollection(Type,{out}Type,{out}Type):Boolean
        //protected override Boolean IsGenericCollection(Type TypeI,out Type TypeG,out Type TypeE) {
        //    if (TypeI == null) { throw new ArgumentNullException(nameof(TypeI)); }
        //    TypeG = default;
        //    TypeE = default;
        //    if (TypeI.IsConstructedGenericType) {
        //        var typeG = TypeI.GetGenericTypeDefinition();
        //        foreach (var type in types) {
        //            if (type.IsAssignableFrom(typeG)) {
        //                TypeG = typeG;
        //                TypeE = TypeI.GenericTypeArguments[0];
        //                return true;
        //                }
        //            }
        //        }
        //    return base.IsGenericCollection(TypeI,out TypeG,out TypeE);
        //    }
        //#endregion

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