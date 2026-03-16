using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(CastCall))]
    internal sealed class SqlFragmentCastCall : SqlFragmentPrimaryExpression<CastCall>
        {
        #region ctor{IServiceProvider,CastCall}
        public SqlFragmentCastCall(IServiceProvider context,CastCall source)
            : base(context,source)
            {
            }
        #endregion
        }
    }