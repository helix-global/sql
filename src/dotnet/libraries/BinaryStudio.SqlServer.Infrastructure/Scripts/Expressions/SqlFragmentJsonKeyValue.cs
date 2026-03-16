using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(JsonKeyValue))]
    internal sealed class SqlFragmentJsonKeyValue : SqlFragmentScalarExpression<JsonKeyValue>
        {
        #region ctor{IServiceProvider,JsonKeyValue}
        public SqlFragmentJsonKeyValue(IServiceProvider context,JsonKeyValue source)
            : base(context,source)
            {
            }
        #endregion
        }
    }