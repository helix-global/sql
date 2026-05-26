using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(VectorDataTypeReference))]
    internal sealed class SqlFragmentVectorDataTypeReference : SqlFragmentDataTypeReference<VectorDataTypeReference>
        {
        #region ctor{IServiceProvider,VectorDataTypeReference}
        public SqlFragmentVectorDataTypeReference(IServiceProvider context,VectorDataTypeReference source)
            : base(context,source)
            {
            }
        #endregion
        }
    }