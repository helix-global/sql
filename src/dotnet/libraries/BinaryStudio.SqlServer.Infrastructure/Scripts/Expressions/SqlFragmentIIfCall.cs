using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(IIfCall))]
    internal sealed class SqlFragmentIIfCall : SqlFragmentPrimaryExpression<IIfCall>
        {
        #region ctor{IServiceProvider,IIfCall}
        public SqlFragmentIIfCall(IServiceProvider context,IIfCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }