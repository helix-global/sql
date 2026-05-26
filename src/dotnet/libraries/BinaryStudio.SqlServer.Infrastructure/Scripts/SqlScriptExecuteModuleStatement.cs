using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlExecuteModuleStatement))]
    internal sealed class SqlScriptExecuteModuleStatement : SqlScriptExecuteStatement<SqlExecuteModuleStatement>
        {
        [UsedImplicitly][Field] public Int32? Number { get; }
        [UsedImplicitly][Field] public IList<SqlScriptExecuteArgument> Arguments { get; }
        [UsedImplicitly][Field] public ISqlScriptModuleOption ModuleOption { get; }
        [UsedImplicitly][Field] public SqlScriptObjectReference Module { get; }

        #region ctor{IServiceProvider,SqlExecuteModuleStatement}
        public SqlScriptExecuteModuleStatement(IServiceProvider context,SqlExecuteModuleStatement source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Module.ToString();
            }
        #endregion
        }
    }