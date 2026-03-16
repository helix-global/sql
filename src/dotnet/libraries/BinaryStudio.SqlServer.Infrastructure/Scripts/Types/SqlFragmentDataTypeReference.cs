using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentDataTypeReference<T> : SqlFragmentObject<T>
        where T : DataTypeReference
        {
        #region ctor{IServiceProvider,T}
        protected SqlFragmentDataTypeReference(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlDataTypeReference))]
    internal sealed class SqlFragmentDataTypeReference : SqlFragmentParameterizedDataTypeReference<SqlDataTypeReference>
        {
        #region ctor{IServiceProvider,SqlDataTypeReference}
        public SqlFragmentDataTypeReference(IServiceProvider context,SqlDataTypeReference source)
            : base(context,source)
            {
            }
        #endregion
        }
    }