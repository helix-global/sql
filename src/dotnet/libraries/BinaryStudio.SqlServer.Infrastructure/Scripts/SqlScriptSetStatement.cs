using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptSetStatement<T> : SqlScriptStatement<T>
        where T: SqlSetStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptSetStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }